<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    protected $table = 'produk';
    protected $primaryKey = 'produk_id';
    
    protected $fillable = [
        'penjual_id',
        'kategori_id', 
        'nama_produk',
        'deskripsi',
        'harga',
        'stok',
        'min_stok',
        'ukuran_stok',
        'size_chart',
    ];
    
    protected $casts = [
        'ukuran_stok' => 'array',
        'harga' => 'integer',
        'stok' => 'integer',
    ];
    
    public function penjual()
    {
        return $this->belongsTo(Penjual::class, 'penjual_id', 'penjual_id');
    }
    
    public function kategori()
    {
        return $this->belongsTo(Kategori::class, 'kategori_id', 'kategori_id');
    }
    
    // Relasi ke gambar produk
    public function gambarProduk()
    {
        return $this->hasMany(GambarProduk::class, 'produk_id', 'produk_id')->orderBy('urutan', 'asc');
    }
    
    // Gambar utama (urutan pertama)
    public function getGambarUtamaAttribute()
    {
        $gambar = $this->gambarProduk()->first();
        return $gambar ? $gambar->gambar : null;
    }
    
    // Ambil semua gambar
    public function getSemuaGambarAttribute()
    {
        return $this->gambarProduk->pluck('gambar')->toArray();
    }
}
