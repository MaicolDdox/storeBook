<?php

use Illuminate\Support\Facades\Route;

Route::get('/health', function () {
    return response()->json([
        'success' => true,
        'message' => 'API is healthy.',
        'data' => [
            'service' => config('app.name'),
        ],
    ]);
});
