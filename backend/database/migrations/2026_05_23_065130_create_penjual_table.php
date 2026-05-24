<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('penjual', function (Blueprint $table) {
            $table->id('penjual_id');
            $table->string('nama', 100);
            $table->string('email', 100)->unique();
            $table->string('kata_sandi');
            $table->string('no_telepon', 20)->nullable();
            $table->string('nama_toko', 100)->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('penjual');
    }
};