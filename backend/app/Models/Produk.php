<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Produk extends Model
{
    protected $table = 'produk';
    protected $primaryKey = 'produk_id';
    
    protected $fillable = [
        'penjual_id',
        'nama_produk',
        'deskripsi',
        'harga',
        'stok',
        'min_stok',
        'kategori',
        'ukuran_stok',
        'gambar',
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
}