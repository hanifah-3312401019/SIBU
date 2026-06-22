<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifikasi', function (Blueprint $table) {
            $table->id('notifikasi_id');
            $table->unsignedBigInteger('penjual_id');
            $table->unsignedBigInteger('produk_id')->nullable();
            $table->text('pesan');
            $table->boolean('sudah_dibaca')->default(false);
            $table->timestamp('waktu_notifikasi')->useCurrent();
            $table->timestamps();

            $table->foreign('penjual_id')->references('penjual_id')->on('penjual')->onDelete('cascade');
            $table->foreign('produk_id')->references('produk_id')->on('produk')->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifikasi');
    }
};