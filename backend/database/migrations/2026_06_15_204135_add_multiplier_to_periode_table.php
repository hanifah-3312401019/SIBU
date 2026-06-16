<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('periode', function (Blueprint $table) {
            $table->decimal('multiplier', 3, 1)->default(1.0)->after('catatan');
        });
    }

    public function down(): void
    {
        Schema::table('periode', function (Blueprint $table) {
            $table->dropColumn('multiplier');
        });
    }
};