<?php

namespace App\Modules\Admin\Services;

use App\Models\Book;
use App\Models\Category;
use App\Models\Genre;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Model;
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
        $payload['slug'] = $this->generateUniqueSlug(Book::class, $payload['title']);
        $payload['status'] = $this->resolveBookStatus($payload);

        return Book::query()->create($payload)->load('category.genre');
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public function updateBook(Book $book, array $payload): Book
    {
        if (isset($payload['title'])) {
            $payload['slug'] = $this->generateUniqueSlug(Book::class, $payload['title'], $book->id);
        }

        $payload['status'] = $this->resolveBookStatus($payload, $book->status);

        $book->update($payload);

        return $book->fresh('category.genre');
    }

    public function deleteBook(Book $book): void
    {
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
}
