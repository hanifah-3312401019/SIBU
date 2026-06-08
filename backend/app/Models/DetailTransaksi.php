<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DetailTransaksi extends Model
{
    protected $table = 'detail_transaksi';
    protected $primaryKey = 'detail_id';
    
    protected $fillable = [
        'transaksi_id',
        'produk_id',
        'jumlah',
        'harga_saat_transaksi',
        'ukuran',
    ];
    
    protected $casts = [
        'jumlah' => 'integer',
        'harga_saat_transaksi' => 'integer',
    ];
    
    public function transaksi()
    {
        return $this->belongsTo(Transaksi::class, 'transaksi_id', 'transaksi_id');
    }
    
    public function produk()
    {
        return $this->belongsTo(Produk::class, 'produk_id', 'produk_id');
    }
}
