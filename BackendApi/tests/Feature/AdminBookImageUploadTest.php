<?php

namespace Tests\Feature;

use App\Models\Book;
use App\Models\Category;
use App\Models\Genre;
use App\Models\User;
use Database\Seeders\RolesAndAdminSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminBookImageUploadTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndAdminSeeder::class);
    }

    public function test_admin_can_create_book_with_cover_image_upload(): void
    {
        Storage::fake('public');

        $admin = User::factory()->create();
        $admin->assignRole('admin');
        Sanctum::actingAs($admin);

        $genre = Genre::query()->create([
            'name' => 'Technology',
            'description' => 'Technology books',
        ]);
        $category = Category::query()->create([
            'genre_id' => $genre->id,
            'name' => 'Programming',
            'slug' => 'programming',
        ]);

        $file = UploadedFile::fake()->image('cover.jpg', 300, 500);

        $response = $this->post('/api/admin/books', [
            'category_id' => $category->id,
            'title' => 'Admin Upload Test',
            'description' => 'Book with uploaded image.',
            'author' => 'Test Author',
            'publisher' => 'Test Publisher',
            'published_year' => 2024,
            'page_count' => 250,
            'stock_quantity' => 10,
            'price_cents' => 2500,
            'status' => 'available',
            'image' => $file,
        ], [
            'Accept' => 'application/json',
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.title', 'Admin Upload Test')
            ->assertJsonPath('data.image_url', $response->json('data.cover_image_url'))
            ->assertJsonPath('data.coverImageUrl', $response->json('data.cover_image_url'));

        $coverImagePath = $response->json('data.cover_image');
        $coverImageUrl = $response->json('data.cover_image_url');
        $bookId = (int) $response->json('data.id');
        $this->assertNotEmpty($coverImagePath);
        $this->assertNotEmpty($coverImageUrl);
        $this->assertStringStartsWith('books/covers/', $coverImagePath);
        $this->assertSame("/api/catalog/books/{$bookId}/cover-image", $coverImageUrl);
        Storage::disk('public')->assertExists($coverImagePath);
    }

    public function test_catalog_cover_endpoint_handles_legacy_absolute_storage_urls(): void
    {
        Storage::fake('public');

        $genre = Genre::query()->create([
            'name' => 'Legacy Genre',
            'description' => 'Legacy genre',
        ]);

        $category = Category::query()->create([
            'genre_id' => $genre->id,
            'name' => 'Legacy Category',
            'slug' => 'legacy-category',
        ]);

        $storedPath = UploadedFile::fake()->image('legacy-cover.png', 200, 300)
            ->store('books/covers', 'public');

        $book = Book::query()->create([
            'category_id' => $category->id,
            'title' => 'Legacy Absolute URL Book',
            'slug' => 'legacy-absolute-url-book',
            'cover_image' => "http://legacy-host.test/storage/{$storedPath}",
            'description' => 'Book with legacy absolute storage URL.',
            'author' => 'Legacy Author',
            'publisher' => 'Legacy Publisher',
            'published_year' => 2024,
            'page_count' => 320,
            'stock_quantity' => 5,
            'price_cents' => 1999,
            'status' => 'available',
        ]);

        $this->getJson("/api/catalog/books/{$book->id}")
            ->assertOk()
            ->assertJsonPath('data.cover_image_url', "/api/catalog/books/{$book->id}/cover-image");

        $this->get("/api/catalog/books/{$book->id}/cover-image")
            ->assertOk();
    }
}
