<?php

namespace App\Modules\Catalog\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Book;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class BookCoverImageController extends Controller
{
    public function show(Book $book): BinaryFileResponse|Response
    {
        $path = $this->normalizeCoverImagePath($book->cover_image);

        if ($path === null || ! Storage::disk('public')->exists($path)) {
            abort(404, 'Book cover image not found.');
        }

        $absolutePath = Storage::disk('public')->path($path);
        $mimeType = Storage::disk('public')->mimeType($path) ?: 'application/octet-stream';

        return response()->file($absolutePath, [
            'Content-Type' => $mimeType,
            'Cache-Control' => 'public, max-age=86400',
        ]);
    }

    private function normalizeCoverImagePath(?string $coverImage): ?string
    {
        if ($coverImage === null || trim($coverImage) === '') {
            return null;
        }

        if (Str::startsWith($coverImage, ['http://', 'https://'])) {
            $absolutePath = parse_url($coverImage, PHP_URL_PATH);
            if (! is_string($absolutePath) || trim($absolutePath) === '') {
                return null;
            }

            $normalizedPath = ltrim($absolutePath, '/');
        } else {
            $normalizedPath = ltrim($coverImage, '/');
        }

        if (Str::startsWith($normalizedPath, 'storage/')) {
            $normalizedPath = Str::after($normalizedPath, 'storage/');
        }

        if (Str::startsWith($normalizedPath, 'public/')) {
            $normalizedPath = Str::after($normalizedPath, 'public/');
        }

        return trim($normalizedPath) === '' ? null : $normalizedPath;
    }
}
