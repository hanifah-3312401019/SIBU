<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transaksi', function (Blueprint $table) {
            $table->id('transaksi_id');
            $table->string('nomor_invoice', 50)->unique();
            $table->unsignedBigInteger('penjual_id');
            $table->bigInteger('total');
            $table->enum('status', ['pending', 'selesai', 'dibatalkan'])->default('selesai');
            $table->timestamp('tanggal_transaksi')->useCurrent();
            $table->timestamps();
            
            $table->foreign('penjual_id')->references('penjual_id')->on('penjual')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transaksi');
    }
};