<?php

use App\Modules\Catalog\Http\Controllers\BookCatalogController;
use App\Modules\Catalog\Http\Controllers\BookCoverImageController;
use App\Modules\Catalog\Http\Controllers\CategoryCatalogController;
use App\Modules\Catalog\Http\Controllers\GenreCatalogController;
use Illuminate\Support\Facades\Route;

Route::prefix('catalog')->group(function (): void {
    Route::get('/books', [BookCatalogController::class, 'index'])->middleware('throttle:search');
    Route::get('/books/{book}', [BookCatalogController::class, 'show']);
    Route::get('/books/{book}/cover-image', [BookCoverImageController::class, 'show'])->name('catalog.books.cover-image');
    Route::get('/categories', [CategoryCatalogController::class, 'index']);
    Route::get('/genres', [GenreCatalogController::class, 'index']);
});
