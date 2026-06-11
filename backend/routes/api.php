<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Api\ProdukController;
use App\Http\Controllers\Api\TransaksiController;

// Auth
Route::post('/login', [LoginController::class, 'login']);

// Kategori (Public)
Route::get('/kategori', [ProdukController::class, 'getKategori']);

// Produk publik untuk pembeli (tidak perlu login)
Route::get('/produk-publik', [ProdukController::class, 'indexPembeli']);
Route::get('/produk-publik/{id}', [ProdukController::class, 'showPembeli']);
Route::get('/rekomendasi', [ProdukController::class, 'rekomendasi']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [LoginController::class, 'logout']);
    Route::get('/me', [LoginController::class, 'me']);
    
    // CRUD Produk
    Route::apiResource('produk', ProdukController::class);
    
    // Transaksi
    Route::apiResource('transaksi', TransaksiController::class);
    Route::get('riwayat-transaksi', [TransaksiController::class, 'index']);
});
