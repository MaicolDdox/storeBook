<?php

namespace App\Modules\Catalog\Services;

use App\Models\Book;
use App\Models\Category;
use App\Models\Genre;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class CatalogService
{
    /**
     * @param  array<string, mixed>  $filters
     */
    public function listBooks(array $filters): LengthAwarePaginator
    {
        $query = Book::query()->with(['category.genre']);

        if (! empty($filters['search'])) {
            $search = $filters['search'];
            $query->where(function ($builder) use ($search): void {
                $builder->where('title', 'like', "%{$search}%")
                    ->orWhere('author', 'like', "%{$search}%")
                    ->orWhere('publisher', 'like', "%{$search}%");
            });
        }

        if (! empty($filters['category_id'])) {
            $query->where('category_id', (int) $filters['category_id']);
        }

        if (! empty($filters['genre_id'])) {
            $query->whereHas('category', function ($builder) use ($filters): void {
                $builder->where('genre_id', (int) $filters['genre_id']);
            });
        }

        if (! empty($filters['status'])) {
            $query->where('status', $filters['status']);
        } else {
            $query->where('status', '!=', 'archived');
        }

        $sort = $filters['sort'] ?? 'newest';
        match ($sort) {
            'price_asc' => $query->orderBy('price_cents'),
            'price_desc' => $query->orderByDesc('price_cents'),
            'title_asc' => $query->orderBy('title'),
            default => $query->orderByDesc('created_at'),
        };

        $perPage = (int) ($filters['per_page'] ?? 12);

        return $query->paginate($perPage)->withQueryString();
    }

    public function listCategories(int $perPage = 20): LengthAwarePaginator
    {
        return Category::query()
            ->with('genre')
            ->orderBy('name')
            ->paginate($perPage);
    }

    public function listGenres(int $perPage = 20): LengthAwarePaginator
    {
        return Genre::query()
            ->orderBy('name')
            ->paginate($perPage);
    }
}
