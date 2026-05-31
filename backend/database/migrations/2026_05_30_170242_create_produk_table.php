<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('produk', function (Blueprint $table) {
            $table->id('produk_id');
            $table->unsignedBigInteger('penjual_id');
            $table->string('nama_produk', 200);
            $table->text('deskripsi')->nullable();
            $table->bigInteger('harga');
            $table->integer('stok')->default(0);
            $table->integer('min_stok')->default(10);
            $table->string('kategori', 100);
            $table->json('ukuran_stok')->nullable();
            $table->string('gambar')->nullable();
            $table->timestamps();
            
            $table->foreign('penjual_id')->references('penjual_id')->on('penjual')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('produk');
    }
};