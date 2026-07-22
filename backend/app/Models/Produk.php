<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    use HasFactory;
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
        'sedang_restock',
        'jumlah_dipesan',
        'jumlah_per_ukuran',
    ];
    
    protected $casts = [
        'ukuran_stok' => 'array',
        'harga' => 'integer',
        'stok' => 'integer',
        'sedang_restock' => 'boolean',
        'jumlah_dipesan' => 'integer',
        'jumlah_per_ukuran' => 'array',
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
        $gambar = $this->gambarProduk->first();
        return $gambar ? $gambar->gambar : null;
    }
    
    // Ambil semua gambar
    public function getSemuaGambarAttribute()
    {
        return $this->gambarProduk->pluck('gambar')->toArray();
    }

    // Method mengurangi stok
    public function kurangiStok($jumlah)
    {
        $this->stok -= $jumlah;
        $this->save();
    }
}
