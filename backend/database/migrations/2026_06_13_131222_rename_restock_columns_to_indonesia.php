<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('produk', function (Blueprint $table) {
            $table->renameColumn('is_restocking', 'sedang_restock');
            
            $table->renameColumn('restock_jumlah', 'jumlah_dipesan');
        });
    }

    public function down(): void
    {
        Schema::table('produk', function (Blueprint $table) {
            $table->renameColumn('sedang_restock', 'is_restocking');
            $table->renameColumn('jumlah_dipesan', 'restock_jumlah');
        });
    }
};