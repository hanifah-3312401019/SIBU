<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class PenjualSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('penjual')->insert([
            [
                'nama' => 'Admin Butik',
                'email' => 'admin@butik.com',
                'kata_sandi' => Hash::make('admin123'),
                'no_telepon' => '081234567890',
                'nama_toko' => 'Butik Syar\'i Ani',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'nama' => 'Ani Fitriani',
                'email' => 'ani@butik.com',
                'kata_sandi' => Hash::make('123456'),
                'no_telepon' => '081234567891',
                'nama_toko' => 'Butik Syar\'i Ani',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);
    }
}