<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Kategori extends Model
{
    use HasFactory;
    protected $table = 'kategori';
    protected $primaryKey = 'kategori_id';
    
    protected $fillable = [
        'nama_kategori',
    ];
    
    public function produk()
    {
        return $this->hasMany(Produk::class, 'kategori_id', 'kategori_id');
    }
}
