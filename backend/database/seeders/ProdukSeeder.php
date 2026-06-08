<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class ProdukSeeder extends Seeder
{
    public function run(): void
    {
       
        DB::table('produk')->delete();
        DB::statement('ALTER TABLE produk AUTO_INCREMENT = 1');
        
        $kategoriAbaya = DB::table('kategori')->where('nama_kategori', 'Abaya')->first();
        
        if ($kategoriAbaya) {
            $produk = [
                [
                    'penjual_id' => 1,
                    'kategori_id' => $kategoriAbaya->kategori_id,
                    'nama_produk' => 'Abaya Cokelat Elegan',
                    'deskripsi' => 'Abaya elegan warna cokelat',
                    'harga' => 385000,
                    'stok' => 15,
                    'min_stok' => 10,
                    'kategori' => 'Abaya',
                    'ukuran_stok' => json_encode([['size' => 'S', 'stock' => 5], ['size' => 'M', 'stock' => 5], ['size' => 'L', 'stock' => 5]]),
                    'gambar' => 'images/abaya_cokelat.jpg',
                    'size_chart' => null,
                    'created_at' => now(),
                    'updated_at' => now(),
                ],
            ];
            
            DB::table('produk')->insert($produk);
        }
    }
}