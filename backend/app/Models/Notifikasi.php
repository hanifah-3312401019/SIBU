<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Notifikasi extends Model
{
    protected $table = 'notifikasi';
    protected $primaryKey = 'notifikasi_id';

    protected $fillable = [
        'penjual_id',
        'produk_id',
        'pesan',
        'sudah_dibaca',
        'waktu_notifikasi',
    ];

    protected $casts = [
        'sudah_dibaca' => 'boolean',
        'waktu_notifikasi' => 'datetime',
    ];

    public function penjual()
    {
        return $this->belongsTo(Penjual::class, 'penjual_id', 'penjual_id');
    }

    public function produk()
    {
        return $this->belongsTo(Produk::class, 'produk_id', 'produk_id');
    }
}