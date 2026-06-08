<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class GambarProduk extends Model
{
    protected $table = 'gambar_produk';
    protected $primaryKey = 'gambar_id';
    
    protected $fillable = [
        'produk_id',
        'gambar',
        'urutan',
    ];
    
    public function produk()
    {
        return $this->belongsTo(Produk::class, 'produk_id', 'produk_id');
    }
}
