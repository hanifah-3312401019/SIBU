<?php

namespace Database\Factories;

use App\Models\Transaksi;
use App\Models\Penjual;
use Illuminate\Database\Eloquent\Factories\Factory;

class TransaksiFactory extends Factory
{
    protected $model = Transaksi::class;

    public function definition()
    {
        return [
            'nomor_invoice' => 'INV-' . $this->faker->date('Ymd') . '-' . $this->faker->unique()->numberBetween(1, 9999),
            'penjual_id' => Penjual::factory(),
            'total' => $this->faker->numberBetween(100000, 1000000),
            'status' => 'selesai',
            'tanggal_transaksi' => $this->faker->dateTimeBetween('-1 month', 'now'),
        ];
    }
}