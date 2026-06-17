<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaksi;
use App\Models\DetailTransaksi;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class LaporanController extends Controller
{
    // GET /api/laporan/penjualan
    public function getPenjualan(Request $request)
    {
        $user = $request->user();
        $periode = $request->get('periode', 'harian');
        $tanggal = $request->get('tanggal', now()->toDateString());

        $data = match ($periode) {
            'harian' => $this->getPenjualanHarian($user->penjual_id, $tanggal),
            'mingguan' => $this->getPenjualanMingguan($user->penjual_id, $tanggal),
            'bulanan' => $this->getPenjualanBulanan($user->penjual_id, $tanggal),
            default => $this->getPenjualanHarian($user->penjual_id, $tanggal),
        };

        return response()->json([
            'success' => true,
            'data' => $data
        ]);
    }

    // GET /api/laporan/penjualan/tahunan
    public function getPenjualanTahunan(Request $request)
    {
        $user = $request->user();
        $tahun = $request->get('tahun', now()->year);

        return response()->json([
            'success' => true,
            'data' => $this->getPenjualanTahunanData($user->penjual_id, $tahun)
        ]);
    }

    // GET /api/laporan/produk-terlaris
    public function getProdukTerlaris(Request $request)
    {
        $user = $request->user();
        $periode = $request->get('periode', 'harian');
        $tanggal = $request->get('tanggal', now()->toDateString());

        $query = DetailTransaksi::query()
            ->join('transaksi', 'detail_transaksi.transaksi_id', '=', 'transaksi.transaksi_id')
            ->join('produk', 'detail_transaksi.produk_id', '=', 'produk.produk_id')
            ->leftJoin('gambar_produk', function ($join) {
                $join->on('produk.produk_id', '=', 'gambar_produk.produk_id')
                    ->where('gambar_produk.urutan', 0);
            })
            ->where('transaksi.penjual_id', $user->penjual_id)
            ->where('transaksi.status', 'selesai');

        // Filter berdasarkan periode
        $date = Carbon::parse($tanggal);
        switch ($periode) {
            case 'harian':
                $query->whereDate('transaksi.tanggal_transaksi', $date);
                break;
            case 'mingguan':
                $startOfWeek = $date->copy()->startOfWeek(Carbon::MONDAY);
                $endOfWeek = $date->copy()->endOfWeek(Carbon::SUNDAY);
                $query->whereBetween('transaksi.tanggal_transaksi', [$startOfWeek, $endOfWeek]);
                break;
            case 'bulanan':
                $query->whereYear('transaksi.tanggal_transaksi', $date->year)
                      ->whereMonth('transaksi.tanggal_transaksi', $date->month);
                break;
        }

        $produkTerlaris = $query
            ->select(
                'produk.produk_id',
                'produk.nama_produk',
                'produk.harga',
                DB::raw('SUM(detail_transaksi.jumlah) as total_terjual'),
                DB::raw('SUM(detail_transaksi.jumlah * detail_transaksi.harga_saat_transaksi) as total_penjualan'),
                'gambar_produk.gambar as gambar'
            )
            ->groupBy('produk.produk_id', 'produk.nama_produk', 'produk.harga', 'gambar_produk.gambar')
            ->orderBy('total_terjual', 'desc')
            ->limit(3)
            ->get();

        // Konversi ke tipe data konsisten (int)
        $produkTerlaris = $produkTerlaris->map(function($item) {
            return [
                'produk_id' => (int) $item->produk_id,
                'nama_produk' => $item->nama_produk,
                'harga' => (int) $item->harga,
                'total_terjual' => (int) $item->total_terjual,
                'total_penjualan' => (int) $item->total_penjualan,
                'gambar' => $item->gambar,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $produkTerlaris
        ]);
    }

    // GET /api/laporan/produk-terlaris/tahunan
    public function getProdukTerlarisTahunan(Request $request)
    {
        $user = $request->user();
        $tahun = $request->get('tahun', now()->year);

        $query = DetailTransaksi::query()
            ->join('transaksi', 'detail_transaksi.transaksi_id', '=', 'transaksi.transaksi_id')
            ->join('produk', 'detail_transaksi.produk_id', '=', 'produk.produk_id')
            ->leftJoin('gambar_produk', function ($join) {
                $join->on('produk.produk_id', '=', 'gambar_produk.produk_id')
                    ->where('gambar_produk.urutan', 0);
            })
            ->where('transaksi.penjual_id', $user->penjual_id)
            ->where('transaksi.status', 'selesai')
            ->whereYear('transaksi.tanggal_transaksi', $tahun);

        $produkTerlaris = $query
            ->select(
                'produk.produk_id',
                'produk.nama_produk',
                'produk.harga',
                DB::raw('SUM(detail_transaksi.jumlah) as total_terjual'),
                DB::raw('SUM(detail_transaksi.jumlah * detail_transaksi.harga_saat_transaksi) as total_penjualan'),
                'gambar_produk.gambar as gambar'
            )
            ->groupBy('produk.produk_id', 'produk.nama_produk', 'produk.harga', 'gambar_produk.gambar')
            ->orderBy('total_terjual', 'desc')
            ->limit(3)
            ->get();

        $produkTerlaris = $produkTerlaris->map(function($item) {
            return [
                'produk_id' => (int) $item->produk_id,
                'nama_produk' => $item->nama_produk,
                'harga' => (int) $item->harga,
                'total_terjual' => (int) $item->total_terjual,
                'total_penjualan' => (int) $item->total_penjualan,
                'gambar' => $item->gambar,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $produkTerlaris
        ]);
    }

    private function getPenjualanHarian($penjualId, $tanggal)
    {
        $date = Carbon::parse($tanggal);
        
        $transaksi = Transaksi::where('penjual_id', $penjualId)
            ->where('status', 'selesai')
            ->whereDate('tanggal_transaksi', $date)
            ->get();

        $totalPenjualan = (int) $transaksi->sum('total');
        $jumlahTransaksi = $transaksi->count();

        $labels = [];
        $values = [];
        $transactionCounts = [];

        for ($i = 7; $i <= 23; $i++) {
            $labels[] = $i . ':00';
            $values[] = 0;
            $transactionCounts[] = 0;
        }

        foreach ($transaksi as $t) {
            $jam = Carbon::parse($t->tanggal_transaksi)->hour;
            if ($jam >= 7 && $jam <= 23) {
                $index = $jam - 7;
                $values[$index] += (int) $t->total;
                $transactionCounts[$index] += 1;
            }
        }

        $maxValue = max($values) > 0 ? max($values) : 1;
        $normalizedValues = array_map(function($v) use ($maxValue) {
            return (int) round(($v / $maxValue) * 100);
        }, $values);

        return [
            'periode' => 'harian',
            'tanggal' => $date->format('Y-m-d'),
            'total_penjualan' => $totalPenjualan,
            'jumlah_transaksi' => $jumlahTransaksi,
            'labels' => $labels,
            'values' => $values,
            'normalized_values' => $normalizedValues,
            'transaction_counts' => $transactionCounts,
        ];
    }

    private function getPenjualanMingguan($penjualId, $tanggal)
    {
        $date = Carbon::parse($tanggal);
        $startOfWeek = $date->copy()->startOfWeek(Carbon::MONDAY);
        $endOfWeek = $date->copy()->endOfWeek(Carbon::SUNDAY);

        $transaksi = Transaksi::where('penjual_id', $penjualId)
            ->where('status', 'selesai')
            ->whereBetween('tanggal_transaksi', [$startOfWeek, $endOfWeek])
            ->get();

        $totalPenjualan = (int) $transaksi->sum('total');
        $jumlahTransaksi = $transaksi->count();

        $hariIndonesia = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
        $labels = [];
        $values = [];
        $transactionCounts = [];

        for ($i = 0; $i < 7; $i++) {
            $hari = $startOfWeek->copy()->addDays($i);
            $labels[] = $hariIndonesia[$i];
            $values[$i] = 0;
            $transactionCounts[$i] = 0;
        }

        foreach ($transaksi as $t) {
            $tgl = Carbon::parse($t->tanggal_transaksi);
            $dayOfWeek = $tgl->dayOfWeekIso;
            $index = $dayOfWeek - 1;
            if ($index >= 0 && $index < 7) {
                $values[$index] += (int) $t->total;
                $transactionCounts[$index] += 1;
            }
        }

        $maxValue = max($values) > 0 ? max($values) : 1;
        $normalizedValues = array_map(function($v) use ($maxValue) {
            return (int) round(($v / $maxValue) * 100);
        }, $values);

        return [
            'periode' => 'mingguan',
            'start_date' => $startOfWeek->format('Y-m-d'),
            'end_date' => $endOfWeek->format('Y-m-d'),
            'total_penjualan' => $totalPenjualan,
            'jumlah_transaksi' => $jumlahTransaksi,
            'labels' => $labels,
            'values' => $values,
            'normalized_values' => $normalizedValues,
            'transaction_counts' => $transactionCounts,
        ];
    }

    private function getPenjualanBulanan($penjualId, $tanggal)
    {
        $date = Carbon::parse($tanggal);
        $year = $date->year;
        $month = $date->month;
        
        $labels = [];
        $values = [];
        $transactionCounts = [];

        $daysInMonth = $date->daysInMonth;
        
        for ($day = 1; $day <= $daysInMonth; $day++) {
            $labels[] = $day;
            $values[$day] = 0;
            $transactionCounts[$day] = 0;
        }

        $transaksi = Transaksi::where('penjual_id', $penjualId)
            ->where('status', 'selesai')
            ->whereYear('tanggal_transaksi', $year)
            ->whereMonth('tanggal_transaksi', $month)
            ->get();

        foreach ($transaksi as $t) {
            $day = (int) Carbon::parse($t->tanggal_transaksi)->format('d');
            if (isset($values[$day])) {
                $values[$day] += (int) $t->total;
                $transactionCounts[$day] += 1;
            }
        }

        $totalPenjualan = (int) $transaksi->sum('total');
        $jumlahTransaksi = $transaksi->count();

        $valuesArray = array_values($values);
        $transactionCountsArray = array_values($transactionCounts);
        $maxValue = max($valuesArray) > 0 ? max($valuesArray) : 1;
        $normalizedValues = array_map(function($v) use ($maxValue) {
            return (int) round(($v / $maxValue) * 100);
        }, $valuesArray);

        $bulanIndonesia = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];

        return [
            'periode' => 'bulanan',
            'tahun' => $year,
            'bulan' => $bulanIndonesia[$month - 1] . ' ' . $year,
            'total_penjualan' => $totalPenjualan,
            'jumlah_transaksi' => $jumlahTransaksi,
            'labels' => $labels,
            'values' => $valuesArray,
            'normalized_values' => $normalizedValues,
            'transaction_counts' => $transactionCountsArray,
        ];
    }

    private function getPenjualanTahunanData($penjualId, $tahun)
    {
        $bulanIndonesia = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
        $labels = [];
        $values = [];
        $transactionCounts = [];

        for ($month = 1; $month <= 12; $month++) {
            $labels[] = $bulanIndonesia[$month - 1];
            
            $total = Transaksi::where('penjual_id', $penjualId)
                ->where('status', 'selesai')
                ->whereYear('tanggal_transaksi', $tahun)
                ->whereMonth('tanggal_transaksi', $month)
                ->sum('total');
            
            $count = Transaksi::where('penjual_id', $penjualId)
                ->where('status', 'selesai')
                ->whereYear('tanggal_transaksi', $tahun)
                ->whereMonth('tanggal_transaksi', $month)
                ->count();

            $values[] = (int) $total;
            $transactionCounts[] = $count;
        }

        $totalPenjualan = array_sum($values);
        $jumlahTransaksi = array_sum($transactionCounts);

        $maxValue = max($values) > 0 ? max($values) : 1;
        $normalizedValues = array_map(function($v) use ($maxValue) {
            return (int) round(($v / $maxValue) * 100);
        }, $values);

        return [
            'periode' => 'tahunan',
            'tahun' => $tahun,
            'total_penjualan' => $totalPenjualan,
            'jumlah_transaksi' => $jumlahTransaksi,
            'labels' => $labels,
            'values' => $values,
            'normalized_values' => $normalizedValues,
            'transaction_counts' => $transactionCounts,
        ];
    }
}
