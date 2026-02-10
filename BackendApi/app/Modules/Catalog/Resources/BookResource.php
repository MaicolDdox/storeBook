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

    private function resolveCoverImageUrl(Request $request): ?string
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

        $configuredAppUrl = rtrim((string) config('app.url'), '/');
        $requestBaseUrl = rtrim($request->getSchemeAndHttpHost(), '/');
        $baseUrl = $configuredAppUrl !== '' ? $configuredAppUrl : $requestBaseUrl;

        if ($this->shouldUseRequestBaseUrl($configuredAppUrl, $requestBaseUrl)) {
            $baseUrl = $requestBaseUrl;
        }

        return $baseUrl.'/api/catalog/books/'.$this->id.'/cover-image';
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

    private function shouldUseRequestBaseUrl(string $configuredAppUrl, string $requestBaseUrl): bool
    {
        if ($requestBaseUrl === '' || $configuredAppUrl === '') {
            return false;
        }

        $configuredHost = (string) parse_url($configuredAppUrl, PHP_URL_HOST);
        $configuredPort = parse_url($configuredAppUrl, PHP_URL_PORT);
        $requestHost = (string) parse_url($requestBaseUrl, PHP_URL_HOST);
        $requestPort = parse_url($requestBaseUrl, PHP_URL_PORT);

        if (! in_array($configuredHost, ['localhost', '127.0.0.1'], true)) {
            return false;
        }

        if ($configuredPort === null) {
            return true;
        }

        if ($requestHost === '') {
            return false;
        }

        if ($requestHost !== $configuredHost) {
            return true;
        }

        return (int) $requestPort !== (int) $configuredPort;
    }
}
