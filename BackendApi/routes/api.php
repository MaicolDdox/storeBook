<?php

use App\Http\Controllers\Auth\SessionAuthController;
use App\Http\Controllers\Auth\TokenAuthController;
use App\Http\Controllers\BookController;
use App\Http\Controllers\CategoryController;
use App\Http\Controllers\TypeController;
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

    //=====================
    //=======RUTAS=========
    //=====================

    //Rutas in Type

});

Route::apiResource('/types', TypeController::class);
Route::apiResource('/categories', CategoryController::class);
Route::apiResource('/books', BookController::class);


