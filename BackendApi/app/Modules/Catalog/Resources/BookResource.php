<?php

namespace App\Modules\Catalog\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

/**
 * @mixin \App\Models\Book
 */
class BookResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $coverImageUrl = $this->resolveCoverImageUrl();

        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'cover_image' => $this->cover_image,
            'cover_image_url' => $coverImageUrl,
            'coverImageUrl' => $coverImageUrl,
            'image_url' => $coverImageUrl,
            'description' => $this->description,
            'author' => $this->author,
            'publisher' => $this->publisher,
            'published_year' => $this->published_year,
            'page_count' => $this->page_count,
            'stock_quantity' => $this->stock_quantity,
            'price_cents' => $this->price_cents,
            'price' => number_format($this->price_cents / 100, 2, '.', ''),
            'status' => $this->status,
            'category' => $this->whenLoaded('category', fn () => new CategoryResource($this->category)),
        ];
    }

    private function resolveCoverImageUrl(): ?string
    {
        $coverImage = trim((string) ($this->cover_image ?? ''));
        if ($coverImage === '') {
            return null;
        }

        if (Str::startsWith($coverImage, ['http://', 'https://'])) {
            return $coverImage;
        }

        $normalizedPath = $this->normalizeCoverImagePath($coverImage);
        if ($normalizedPath === null || ! Storage::disk('public')->exists($normalizedPath)) {
            return null;
        }

        return url(Storage::disk('public')->url($normalizedPath));
    }

    private function normalizeCoverImagePath(string $coverImage): ?string
    {
        $normalizedPath = ltrim($coverImage, '/');

        if (Str::startsWith($normalizedPath, 'storage/')) {
            $normalizedPath = Str::after($normalizedPath, 'storage/');
        }

        if (Str::startsWith($normalizedPath, 'public/')) {
            $normalizedPath = Str::after($normalizedPath, 'public/');
        }

        return trim($normalizedPath) === '' ? null : $normalizedPath;
    }
}
