<?php

namespace Tests\Feature;

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
            ->assertJsonPath('data.title', 'Admin Upload Test');

        $coverImagePath = $response->json('data.cover_image');
        $coverImageUrl = $response->json('data.cover_image_url');

        $this->assertNotEmpty($coverImagePath);
        $this->assertNotEmpty($coverImageUrl);
        Storage::disk('public')->assertExists($coverImagePath);
    }
}
