<?php

use App\Modules\Admin\Http\Controllers\BookAdminController;
use App\Modules\Admin\Http\Controllers\CategoryAdminController;
use App\Modules\Admin\Http\Controllers\DashboardAdminController;
use App\Modules\Admin\Http\Controllers\GenreAdminController;
use App\Modules\Admin\Http\Controllers\OrderAdminController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth:sanctum', 'role:admin'])
    ->prefix('admin')
    ->group(function (): void {
        Route::get('/dashboard', [DashboardAdminController::class, 'index']);

        Route::apiResource('/genres', GenreAdminController::class);
        Route::apiResource('/categories', CategoryAdminController::class);
        Route::apiResource('/books', BookAdminController::class);

        Route::get('/orders', [OrderAdminController::class, 'index']);
        Route::get('/orders/{order}', [OrderAdminController::class, 'show']);
        Route::patch('/orders/{order}/status', [OrderAdminController::class, 'updateStatus']);
    });
