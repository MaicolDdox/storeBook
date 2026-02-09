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
        $coverImageUrl = $this->resolveCoverImageUrl($request);

        return [
            'id' => $this->id,
            'title' => $this->title,
            'slug' => $this->slug,
            'cover_image' => $this->cover_image,
            'cover_image_url' => $coverImageUrl,
            'coverImageUrl' => $coverImageUrl,
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

    private function resolveCoverImageUrl(Request $request): ?string
    {
        $coverImage = (string) ($this->cover_image ?? '');
        if ($coverImage === '') {
            return null;
        }

        if (Str::startsWith($coverImage, ['http://', 'https://'])) {
            return $coverImage;
        }

        $normalizedPath = ltrim($coverImage, '/');
        if (Str::startsWith($normalizedPath, 'storage/')) {
            $normalizedPath = Str::after($normalizedPath, 'storage/');
        }
        if (Str::startsWith($normalizedPath, 'public/')) {
            $normalizedPath = Str::after($normalizedPath, 'public/');
        }

        $storageUrl = Storage::disk('public')->url($normalizedPath);
        $storagePath = Str::startsWith($storageUrl, ['http://', 'https://'])
            ? (string) parse_url($storageUrl, PHP_URL_PATH)
            : $storageUrl;

        if ($storagePath === '') {
            return null;
        }

        return $request->getSchemeAndHttpHost().'/'.ltrim($storagePath, '/');
    }
}
