<?php

namespace Database\Factories;

use App\Models\Produk;
use App\Models\Penjual;
use App\Models\Kategori;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProdukFactory extends Factory
{
    protected $model = Produk::class;

    public function definition()
    {
        return [
            'penjual_id' => Penjual::factory(),
            'kategori_id' => Kategori::factory(),
            'nama_produk' => $this->faker->words(3, true),
            'deskripsi' => $this->faker->sentence(),
            'harga' => $this->faker->numberBetween(50000, 500000),
            'stok' => $this->faker->numberBetween(5, 100),
            'min_stok' => $this->faker->numberBetween(5, 20),
            'ukuran_stok' => [
                ['size' => 'S', 'stock' => 10],
                ['size' => 'M', 'stock' => 15],
                ['size' => 'L', 'stock' => 10],
            ],
        ];
    }
}