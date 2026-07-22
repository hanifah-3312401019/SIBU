<?php

namespace Tests\Feature;

use App\Models\Penjual;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_penjual_bisa_login_dengan_kredensial_benar()
    {
        $penjual = Penjual::factory()->create([
            'email' => 'penjual@example.com',
            'kata_sandi' => Hash::make('password123'),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'penjual@example.com',
            'password' => 'password123',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Login berhasil',
            ])
            ->assertJsonStructure(['token']);
    }

    public function test_login_gagal_jika_password_salah()
    {
        $penjual = Penjual::factory()->create([
            'email' => 'penjual@example.com',
            'kata_sandi' => Hash::make('password123'),
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'penjual@example.com',
            'password' => 'wrongpassword',
        ]);

        $response->assertStatus(401)
            ->assertJson([
                'success' => false,
                'message' => 'Password salah',
            ]);
    }

    public function test_penjual_bisa_mengambil_data_profil_sendiri()
    {
        $penjual = Penjual::factory()->create();

        $response = $this->actingAs($penjual, 'sanctum')
            ->getJson('/api/me');

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'penjual_id' => $penjual->penjual_id,
                ],
            ]);
    }

    public function test_penjual_bisa_memperbarui_profil()
    {
        $penjual = Penjual::factory()->create();

        $response = $this->actingAs($penjual, 'sanctum')
            ->putJson('/api/me', [
                'nama' => 'Nama Baru Toko',
                'no_telepon' => '081234567890',
            ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'message' => 'Profil berhasil diperbarui',
            ]);

        $this->assertDatabaseHas('penjual', [
            'penjual_id' => $penjual->penjual_id,
            'nama' => 'Nama Baru Toko',
            'no_telepon' => '081234567890',
        ]);
    }
}