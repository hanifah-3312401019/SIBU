<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('produk', function (Blueprint $table) {
            $table->unsignedBigInteger('kategori_id')->nullable()->after('penjual_id');
            
            $table->string('size_chart')->nullable()->after('gambar');
            
            $table->foreign('kategori_id')
                  ->references('kategori_id')
                  ->on('kategori')
                  ->onDelete('set null');
        });
    }

    public function down(): void
    {
        Schema::table('produk', function (Blueprint $table) {
            $table->dropForeign(['kategori_id']);
            
            $table->dropColumn('kategori_id');
            $table->dropColumn('size_chart');
        });
    }
};