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
        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'cover_image' => $this->cover_image,
            'cover_image_url' => $this->resolveCoverImageUrl(),
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
        if (! $this->cover_image) {
            return null;
        }

        if (Str::startsWith($this->cover_image, ['http://', 'https://'])) {
            return $this->cover_image;
        }

        return Storage::disk('public')->url($this->cover_image);
    }
}
