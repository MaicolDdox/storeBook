<?php

use Illuminate\Support\Facades\Route;

Route::view('/', 'welcome');

Route::get('/status', fn () => ['status' => 'ok']);
