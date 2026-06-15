<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('produk', function (Blueprint $table) {
            $table->boolean('is_restocking')->default(false)->after('stok');
            $table->integer('restock_jumlah')->nullable()->after('is_restocking');
        });
    }

    public function down(): void
    {
        Schema::table('produk', function (Blueprint $table) {
            $table->dropColumn('is_restocking');
            $table->dropColumn('restock_jumlah');
        });
    }
};