<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('gambar_produk', function (Blueprint $table) {
            $table->id('gambar_id');
            $table->unsignedBigInteger('produk_id');
            $table->string('gambar', 255);
            $table->integer('urutan')->default(0);
            $table->timestamps();
            
            $table->foreign('produk_id')->references('produk_id')->on('produk')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('gambar_produk');
    }
};