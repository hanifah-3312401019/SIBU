<?php

namespace Tests\Unit;

use App\Models\Penjual;
use Tests\TestCase;

class PenjualTest extends TestCase
{
    public function test_get_auth_password_mengembalikan_field_kata_sandi()
    {
        $penjual = new Penjual([
            'kata_sandi' => 'hashed_password_123',
        ]);

        $this->assertEquals('hashed_password_123', $penjual->getAuthPassword());
    }
}