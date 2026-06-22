<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasColumn('penjual', 'fcm_token')) {
            Schema::table('penjual', function (Blueprint $table) {
                $table->text('fcm_token')->nullable()->after('nama_toko');
            });
        }
    }

    public function down(): void
    {
        if (Schema::hasColumn('penjual', 'fcm_token')) {
            Schema::table('penjual', function (Blueprint $table) {
                $table->dropColumn('fcm_token');
            });
        }
    }
};