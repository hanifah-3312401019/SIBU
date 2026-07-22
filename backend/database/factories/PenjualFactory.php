<?php

namespace Database\Factories;

use App\Models\Penjual;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

class PenjualFactory extends Factory
{
    protected $model = Penjual::class;

    public function definition()
    {
        return [
            'nama' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'kata_sandi' => Hash::make('password'),
            'no_telepon' => $this->faker->phoneNumber(),
            'nama_toko' => $this->faker->company(),
        ];
    }
}