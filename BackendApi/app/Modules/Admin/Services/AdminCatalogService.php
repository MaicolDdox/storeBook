<?php

namespace App\Modules\Admin\Services;

use App\Models\Book;
use App\Models\Category;
use App\Models\Genre;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AdminCatalogService
{
    public function listGenres(int $perPage = 20): LengthAwarePaginator
    {
        return Genre::query()->orderBy('name')->paginate($perPage);
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public function createGenre(array $payload): Genre
    {
        return Genre::query()->create($payload);
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public function updateGenre(Genre $genre, array $payload): Genre
    {
        $genre->update($payload);

        return $genre->fresh();
    }

    public function deleteGenre(Genre $genre): void
    {
        $genre->delete();
    }

    public function listCategories(int $perPage = 20): LengthAwarePaginator
    {
        return Category::query()->with('genre')->orderBy('name')->paginate($perPage);
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public function createCategory(array $payload): Category
    {
        $payload['slug'] = $this->generateUniqueSlug(Category::class, $payload['name']);

        return Category::query()->create($payload)->load('genre');
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public function updateCategory(Category $category, array $payload): Category
    {
        if (isset($payload['name'])) {
            $payload['slug'] = $this->generateUniqueSlug(Category::class, $payload['name'], $category->id);
        }

        $category->update($payload);

        return $category->fresh('genre');
    }

    public function deleteCategory(Category $category): void
    {
        $category->delete();
    }

    public function listBooks(int $perPage = 20): LengthAwarePaginator
    {
        return Book::query()
            ->with('category.genre')
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public function createBook(array $payload): Book
    {
        $payload = $this->prepareBookPayload($payload);
        $payload['slug'] = $this->generateUniqueSlug(Book::class, $payload['title']);
        $payload['status'] = $this->resolveBookStatus($payload);

        return Book::query()->create($payload)->load('category.genre');
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public function updateBook(Book $book, array $payload): Book
    {
        $oldCoverImage = $book->cover_image;
        $payload = $this->prepareBookPayload($payload);

        if (isset($payload['title'])) {
            $payload['slug'] = $this->generateUniqueSlug(Book::class, $payload['title'], $book->id);
        }

        $payload['status'] = $this->resolveBookStatus($payload, $book->status);

        $book->update($payload);
        if (
            isset($payload['cover_image']) &&
            $payload['cover_image'] !== $oldCoverImage &&
            $this->isStoredCoverImagePath($oldCoverImage)
        ) {
            $this->deleteCoverImageFromPublicDisk($oldCoverImage);
        }

        return $book->fresh('category.genre');
    }

    public function deleteBook(Book $book): void
    {
        if ($this->isStoredCoverImagePath($book->cover_image)) {
            $this->deleteCoverImageFromPublicDisk($book->cover_image);
        }

        $book->delete();
    }

    /**
     * @param  class-string<Model>  $modelClass
     */
    private function generateUniqueSlug(string $modelClass, string $source, ?int $ignoreId = null): string
    {
        $baseSlug = Str::slug($source);
        $baseSlug = $baseSlug === '' ? 'item' : $baseSlug;

        $slug = $baseSlug;
        $sequence = 1;

        while ($modelClass::query()
            ->where('slug', $slug)
            ->when($ignoreId !== null, fn ($query) => $query->where('id', '!=', $ignoreId))
            ->exists()) {
            $sequence++;
            $slug = "{$baseSlug}-{$sequence}";
        }

        return $slug;
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    private function resolveBookStatus(array $payload, string $fallbackStatus = 'available'): string
    {
        $stock = $payload['stock_quantity'] ?? null;
        $status = $payload['status'] ?? $fallbackStatus;

        if ($stock !== null && (int) $stock === 0 && $status === 'available') {
            return 'out_of_stock';
        }

        return $status;
    }

    /**
     * @param  array<string, mixed>  $payload
     * @return array<string, mixed>
     */
    private function prepareBookPayload(array $payload): array
    {
        $removeImage = (bool) ($payload['remove_image'] ?? false);
        unset($payload['remove_image']);

        if (isset($payload['image']) && $payload['image'] instanceof UploadedFile) {
            $payload['cover_image'] = $payload['image']->store('books/covers', 'public');
        } elseif ($removeImage) {
            $payload['cover_image'] = null;
        }

        unset($payload['image']);

        return $payload;
    }

    private function isStoredCoverImagePath(?string $coverImage): bool
    {
        if ($coverImage === null || $coverImage === '') {
            return false;
        }

        return ! Str::startsWith($coverImage, ['http://', 'https://']);
    }

    private function deleteCoverImageFromPublicDisk(?string $coverImage): void
    {
        if ($coverImage === null || $coverImage === '') {
            return;
        }

        $normalizedPath = ltrim($coverImage, '/');
        if (Str::startsWith($normalizedPath, 'storage/')) {
            $normalizedPath = Str::after($normalizedPath, 'storage/');
        }
        if (Str::startsWith($normalizedPath, 'public/')) {
            $normalizedPath = Str::after($normalizedPath, 'public/');
        }

        if ($normalizedPath !== '') {
            Storage::disk('public')->delete($normalizedPath);
        }
    }
}
