<?php

namespace Tests\Unit;

use App\Models\GambarProduk;
use App\Models\Produk;
use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    public function test_method_kurangi_stok_berfungsi()
    {
        // Pakai factory agar penjual_id dan field wajib lainnya dibuatkan otomatis!
        $produk = Produk::factory()->create([
            'stok' => 15,
        ]);

        $produk->kurangiStok(5);

        // Pastikan nilai di database sudah ter-update
        $this->assertEquals(10, $produk->fresh()->stok);
    }

    public function test_attribute_gambar_utama_mengembalikan_gambar_pertama()
    {
        $produk = new Produk(['produk_id' => 1]);
        
        $gambar1 = new GambarProduk(['gambar' => 'path/ke/gambar1.jpg', 'urutan' => 1]);
        $gambar2 = new GambarProduk(['gambar' => 'path/ke/gambar2.jpg', 'urutan' => 2]);

        $produk->setRelation('gambarProduk', collect([$gambar1, $gambar2]));

        $this->assertEquals('path/ke/gambar1.jpg', $produk->gambarUtama);
    }
}