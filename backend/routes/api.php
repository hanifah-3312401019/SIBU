<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Api\ProdukController;

// Auth
Route::post('/login', [LoginController::class, 'login']);

// Protected routes dengan middleware sanctum
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [LoginController::class, 'logout']);
    Route::get('/me', [LoginController::class, 'me']);
    
    // CRUD Produk
    Route::apiResource('produk', ProdukController::class);
});