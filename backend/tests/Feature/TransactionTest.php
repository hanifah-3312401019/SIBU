<?php

namespace Tests\Feature;

use App\Models\Penjual;
use App\Models\Produk;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class TransactionTest extends TestCase
{
    use RefreshDatabase;

    public function test_membuat_transaksi_berhasil_dan_mengurangi_stok()
    {
        $penjual = Penjual::factory()->create();
        
        $ukuranStok = [
            ['size' => 'M', 'stock' => 5],
            ['size' => 'L', 'stock' => 5],
        ];

        $produk = Produk::factory()->create([
            'penjual_id' => $penjual->penjual_id,
            'stok' => 10,
            'min_stok' => 2,
            'harga' => 100000,
            'ukuran_stok' => $ukuranStok,
        ]);

        $payload = [
            'items' => [
                [
                    'produk_id' => $produk->produk_id,
                    'jumlah' => 2,
                    'ukuran' => 'M',
                ],
            ],
        ];

        $response = $this->actingAs($penjual, 'sanctum')
            ->postJson('/api/transaksi', $payload);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'message' => 'Transaksi berhasil disimpan',
            ]);

        // Cek pengurangan stok di database
        $produk->refresh();
        $this->assertEquals(8, $produk->stok);
    }

    public function test_transaksi_gagal_jika_stok_ukuran_tidak_mencukupi()
    {
        $penjual = Penjual::factory()->create();

        $produk = Produk::factory()->create([
            'penjual_id' => $penjual->penjual_id,
            'stok' => 5,
            'ukuran_stok' => [
                ['size' => 'S', 'stock' => 1],
            ],
        ]);

        $payload = [
            'items' => [
                [
                    'produk_id' => $produk->produk_id,
                    'jumlah' => 5, // melebihi stok 'S'
                    'ukuran' => 'S',
                ],
            ],
        ];

        $response = $this->actingAs($penjual, 'sanctum')
            ->postJson('/api/transaksi', $payload);

        $response->assertStatus(400)
            ->assertJson([
                'success' => false,
            ]);
    }
}