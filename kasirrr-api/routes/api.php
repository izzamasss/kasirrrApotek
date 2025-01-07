<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

//auth api
Route::post('/login', [App\Http\Controllers\Api\AuthController::class, 'login']);

// crud pengguna
Route::get('/pengguna', [App\Http\Controllers\Api\AuthController::class, 'show']);
Route::post('/pengguna', [App\Http\Controllers\Api\AuthController::class, 'create']);
Route::put('/pengguna/foto/{id}', [App\Http\Controllers\Api\AuthController::class, 'changeFotoProfil']);
Route::put('/pengguna/reset-password/{id}', [App\Http\Controllers\Api\AuthController::class, 'resetPassword']);
Route::put('/pengguna/change-status/{id}', [App\Http\Controllers\Api\AuthController::class, 'changeStatus']);
Route::put('/pengguna/{id}', [App\Http\Controllers\Api\AuthController::class, 'update']);
Route::delete('/pengguna/{id}', [App\Http\Controllers\Api\AuthController::class, 'destroy']);

// crud kategori
Route::get('/kategori', [App\Http\Controllers\Api\KategoriController::class, 'show']);
Route::post('/kategori', [App\Http\Controllers\Api\KategoriController::class, 'create']);
Route::put('/kategori/{id}', [App\Http\Controllers\Api\KategoriController::class, 'update']);
Route::delete('/kategori/{id}', [App\Http\Controllers\Api\KategoriController::class, 'destroy']);

// crud produk
Route::get('/produk', [App\Http\Controllers\Api\ProdukController::class, 'show']);
Route::post('/produk', [App\Http\Controllers\Api\ProdukController::class, 'create']);
Route::put('/produk/{id}', [App\Http\Controllers\Api\ProdukController::class, 'update']);
Route::delete('/produk/{id}', [App\Http\Controllers\Api\ProdukController::class, 'destroy']);

// crud transaksi
Route::get('/dashboard', [App\Http\Controllers\Api\TransaksiController::class, 'dashboard']);
// Route::get('/logStok', [App\Http\Controllers\Api\TransaksiController::class, 'logStok']);
Route::post('/transaksi', [App\Http\Controllers\Api\TransaksiController::class, 'create']);
// Route::put('/produk/{id}', [App\Http\Controllers\Api\ProdukController::class, 'update']);
// Route::delete('/produk/{id}', [App\Http\Controllers\Api\ProdukController::class, 'destroy']);


// crud log stok
Route::get('/logStok', [App\Http\Controllers\Api\LogStokController::class, 'show']);
Route::post('/logStok', [App\Http\Controllers\Api\LogStokController::class, 'create']);

Route::get('/laporan', [App\Http\Controllers\Api\LaporanKeuanganController::class, 'show']);
