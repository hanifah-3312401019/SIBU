<?php

namespace Tests\Feature;

use App\Models\GambarProduk;
use App\Models\Kategori;
use App\Models\Penjual;
use App\Models\Produk;
use App\Models\Transaksi;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;
use Tests\TestCase;

class ProductTest extends TestCase
{
    use RefreshDatabase;

    public function test_bisa_mengambil_daftar_produk_publik()
    {
        $kategori = Kategori::factory()->create();
        Produk::factory()->create(['kategori_id' => $kategori->kategori_id]);

        $response = $this->getJson('/api/produk-publik');

        $response->assertStatus(200)
            ->assertJson(['success' => true]);
    }

    public function test_penjual_bisa_menambah_produk_baru()
    {
        Storage::fake('public');
        $penjual = Penjual::factory()->create();
        $kategori = Kategori::factory()->create();

        $fileGambar = UploadedFile::fake()->image('produk.jpg');

        $payload = [
            'nama_produk' => 'Baju Batik Smart',
            'harga' => 150000,
            'stok' => 20,
            'min_stok' => 5,
            'kategori_id' => $kategori->kategori_id,
            'ukuran_stok' => json_encode([
                ['size' => 'M', 'stock' => 10],
                ['size' => 'L', 'stock' => 10],
            ]),
            'gambar' => [$fileGambar],
        ];

        $response = $this->actingAs($penjual, 'sanctum')
            ->postJson('/api/produk', $payload);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Produk berhasil ditambahkan',
            ]);

        $this->assertDatabaseHas('produk', [
            'nama_produk' => 'Baju Batik Smart',
            'penjual_id' => $penjual->penjual_id,
        ]);
    }

    public function test_penjual_tidak_bisa_menghapus_produk_yang_punya_riwayat_transaksi()
    {
        $penjual = Penjual::factory()->create();
        $produk = Produk::factory()->create(['penjual_id' => $penjual->penjual_id]);

        // 1. Buat record transaksi induk terlebih dahulu
        $transaksi = Transaksi::factory()->create();

        // 2. Hubungkan detail_transaksi dengan transaksi_id yang sah dari database
        DB::table('detail_transaksi')->insert([
            'transaksi_id' => $transaksi->transaksi_id, // Menggunakan ID transaksi yang baru dibuat
            'produk_id' => $produk->produk_id,
            'jumlah' => 1,
            'harga_saat_transaksi' => 100000,
        ]);

        $response = $this->actingAs($penjual, 'sanctum')
            ->deleteJson("/api/produk/{$produk->produk_id}");

        $response->assertStatus(409)
            ->assertJson([
                'success' => false,
            ]);
    }
}