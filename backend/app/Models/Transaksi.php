<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Transaksi extends Model
{
    protected $table = 'transaksi';
    protected $primaryKey = 'transaksi_id';
    
    protected $fillable = [
        'nomor_invoice',
        'penjual_id',
        'total',
        'status',
        'tanggal_transaksi',
    ];
    
    protected $casts = [
        'tanggal_transaksi' => 'datetime',
        'total' => 'integer',
    ];
    
    public function penjual()
    {
        return $this->belongsTo(Penjual::class, 'penjual_id', 'penjual_id');
    }
    
    public function detailTransaksi()
    {
        return $this->hasMany(DetailTransaksi::class, 'transaksi_id', 'transaksi_id');
    }
}
