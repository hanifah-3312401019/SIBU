<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class KategoriSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('kategori')->delete();
        DB::statement('ALTER TABLE kategori AUTO_INCREMENT = 1');
        
        $kategori = [
            ['nama_kategori' => 'Abaya', 'created_at' => now(), 'updated_at' => now()],
            ['nama_kategori' => 'Gamis', 'created_at' => now(), 'updated_at' => now()],
            ['nama_kategori' => 'Baju Kurung', 'created_at' => now(), 'updated_at' => now()],
            ['nama_kategori' => 'Khimar', 'created_at' => now(), 'updated_at' => now()],
            ['nama_kategori' => 'Bergo', 'created_at' => now(), 'updated_at' => now()],
        ];
        
        DB::table('kategori')->insert($kategori);
    }
}