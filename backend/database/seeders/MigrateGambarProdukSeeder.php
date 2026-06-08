<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class MigrateGambarProdukSeeder extends Seeder
{
    public function run(): void
    {
        $produk = DB::table('produk')->whereNotNull('gambar')->get();
        
        foreach ($produk as $p) {
            if ($p->gambar) {
                DB::table('gambar_produk')->insert([
                    'produk_id' => $p->produk_id,
                    'gambar' => $p->gambar,
                    'urutan' => 0,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }
    }
}