<?php

use App\Http\Controllers\Auth\SessionAuthController;
use App\Http\Controllers\Auth\TokenAuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');


Route::prefix('auth')->group(function (){
    Route::post('/register', [TokenAuthController::class, 'register']);
    Route::post('/login',    [TokenAuthController::class, 'login']);
});

Route::middleware('auth:sanctum')->group(function (){
    Route::get('/me',              [TokenAuthController::class, 'me']);
    Route::post('/auth/logout',    [TokenAuthController::class, 'logout']);
});



