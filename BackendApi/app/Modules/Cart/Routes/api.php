<?php

use App\Modules\Cart\Http\Controllers\CartController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')
    ->prefix('cart')
    ->group(function (): void {
        Route::get('/', [CartController::class, 'show']);
        Route::post('/items', [CartController::class, 'store']);
        Route::patch('/items/{cartItem}', [CartController::class, 'update']);
        Route::delete('/items/{cartItem}', [CartController::class, 'destroy']);
        Route::delete('/items', [CartController::class, 'clear']);
    });
