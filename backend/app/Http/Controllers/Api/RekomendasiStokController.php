<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use App\Models\DetailTransaksi;
use App\Models\Periode;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class RekomendasiStokController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $periodeId = $request->get('periode_id');
        $hariCover = (int) $request->get('hari_cover', 30); 
        
        $periode = null;
        $multiplier = 1.0;
        $sisaHari = 0;
        
        if ($periodeId) {
            $periode = Periode::find($periodeId);
            if ($periode) {
                $multiplier = (float) ($periode->multiplier ?? 1.0);
                $sisaHari = $this->hitungSisaHari($periode->tanggal_selesai);
            }
        }
        
        $produk = Produk::where('penjual_id', $user->penjual_id)
            ->with('gambarProduk', 'kategori')
            ->get();
        
        $rekomendasi = [];
        
        foreach ($produk as $item) {
            // Hitung total terjual berdasarkan periode atau hari cover
            $totalTerjual = $this->hitungTotalTerjual($item->produk_id, $periode, $hariCover);
            $totalHari = $this->hitungTotalHari($periode, $hariCover);
            
            // Rata-rata per hari
            $rataHari = $totalHari > 0 ? round($totalTerjual / $totalHari, 2) : 0;
            
            // Hitung per ukuran
            $ukuranStok = $item->ukuran_stok;
            if (is_string($ukuranStok)) {
                $ukuranStok = json_decode($ukuranStok, true);
            }
            if (!is_array($ukuranStok)) {
                $ukuranStok = [];
            }
            
            // Hitung rekomendasi per ukuran
            $rekomendasiPerUkuran = [];
            $totalRekomendasi = 0;
            $totalSaranTambah = 0;
            
            foreach ($ukuranStok as $uk) {
                $size = $uk['size'];
                $stokUkuran = (int) ($uk['stock'] ?? 0);
                
                $terjualUkuran = $this->hitungTerjualPerUkuran($item->produk_id, $size, $periode, $hariCover);
                $rataUkuran = $totalHari > 0 ? round($terjualUkuran / $totalHari, 2) : 0;
                
                // Kebutuhan = rata-rata × hari cover
                $kebutuhan = round($rataUkuran * $hariCover, 0);
                
                // Rekomendasi = kebutuhan × multiplier
                $rekomendasiUkuran = round($kebutuhan * $multiplier, 0);
                
                // Saran tambah = rekomendasi - stok saat ini
                $saranTambah = $rekomendasiUkuran - $stokUkuran;
                if ($saranTambah < 0) $saranTambah = 0;
                
                $rekomendasiPerUkuran[] = [
                    'size' => $size,
                    'stok_saat_ini' => $stokUkuran,
                    'terjual' => $terjualUkuran,
                    'rata_hari' => $rataUkuran,
                    'kebutuhan' => (int) $kebutuhan,
                    'rekomendasi' => (int) $rekomendasiUkuran,
                    'saran_tambah' => (int) $saranTambah,
                ];
                
                $totalRekomendasi += $rekomendasiUkuran;
                $totalSaranTambah += $saranTambah;
            }
            
            if (empty($ukuranStok)) {
                $kebutuhan = round($rataHari * $hariCover, 0);
                $rekomendasiTotal = round($kebutuhan * $multiplier, 0);
                $saranTambah = $rekomendasiTotal - $item->stok;
                if ($saranTambah < 0) $saranTambah = 0;
                
                $rekomendasiPerUkuran = [];
                $totalRekomendasi = $rekomendasiTotal;
                $totalSaranTambah = $saranTambah;
            }
            
            // Status berdasarkan saran tambah
            if ($item->sedang_restock) {
                $status = 'sudah_dipesan';
            } elseif ($totalSaranTambah > 0) {
                $status = 'perlu_restock';
            } elseif ($item->stok <= $item->min_stok) {
                $status = 'perlu_diperhatikan';
            } else {
                $status = 'cukup';
            }
            
            $rekomendasi[] = [
                'id' => $item->produk_id,
                'nama' => $item->nama_produk,
                'kategori' => $item->kategori?->nama_kategori ?? '',
                'badge' => $periode ? ($periode->nama_periode ?? 'Periode Khusus') : 'Normal',
                'stok' => $item->stok,
                'ukuran_stok' => $ukuranStok,
                'rataHari' => $rataHari,
                'saranTambah' => $totalSaranTambah,
                'rekomendasi_total' => $totalRekomendasi,
                'status' => $status,
                'gambar' => $item->gambarProduk->isNotEmpty() ? $item->gambarProduk->first()->gambar : null,
                'jumlah_dipesan' => $item->jumlah_dipesan,
                'jumlah_per_ukuran' => $item->jumlah_per_ukuran,
                'periode_nama' => $periode ? $periode->nama_periode : null,
                'multiplier' => $multiplier,
                'sisa_hari' => $sisaHari,
                'hari_cover' => $hariCover,
                'total_terjual' => $totalTerjual,
                'rekomendasi_per_ukuran' => $rekomendasiPerUkuran,
            ];
        }
        
        // Urutkan berdasarkan prioritas
        usort($rekomendasi, function ($a, $b) {
            $prioritas = ['perlu_restock' => 0, 'sudah_dipesan' => 1, 'perlu_diperhatikan' => 2, 'cukup' => 3];
            $pa = $prioritas[$a['status']] ?? 5;
            $pb = $prioritas[$b['status']] ?? 5;
            if ($pa !== $pb) return $pa - $pb;
            return $b['saranTambah'] - $a['saranTambah'];
        });
        
        return response()->json([
            'success' => true,
            'data' => $rekomendasi,
            'periode' => $periode ? [
                'id' => $periode->periode_id,
                'nama' => $periode->nama_periode,
                'multiplier' => $multiplier,
                'sisa_hari' => $sisaHari,
            ] : null,
            'hari_cover' => $hariCover,
        ]);
    }
    
    private function hitungSisaHari($tanggalSelesai)
    {
        $now = now()->startOfDay();
        $end = \Carbon\Carbon::parse($tanggalSelesai)->startOfDay();
        
        if ($now->greaterThan($end)) {
            return 0;
        }
        
        return $now->diffInDays($end);
    }
    
    private function hitungTotalHari($periode, $hariCover)
    {
        if ($periode) {
            return $periode->tanggal_mulai->diffInDays($periode->tanggal_selesai) + 1;
        }
        return $hariCover;
    }
    
    private function hitungTotalTerjual($produkId, $periode, $hariCover)
    {
        $query = DetailTransaksi::where('produk_id', $produkId);
        
        if ($periode) {
            $query->whereBetween('created_at', [
                $periode->tanggal_mulai,
                $periode->tanggal_selesai,
            ]);
        } else {
            $query->where('created_at', '>=', now()->subDays($hariCover));
        }
        
        return (int) $query->sum('jumlah');
    }
    
    private function hitungTerjualPerUkuran($produkId, $size, $periode, $hariCover)
    {
        $query = DetailTransaksi::where('produk_id', $produkId)
            ->where('ukuran', $size);
        
        if ($periode) {
            $query->whereBetween('created_at', [
                $periode->tanggal_mulai,
                $periode->tanggal_selesai,
            ]);
        } else {
            $query->where('created_at', '>=', now()->subDays($hariCover));
        }
        
        return (int) $query->sum('jumlah');
    }
    
    // POST /rekomendasi-stok/restock
    public function restock(Request $request)
    {
        $request->validate([
            'produk_id' => 'required|exists:produk,produk_id',
            'jumlah' => 'required|integer|min:1',
            'jumlah_per_ukuran' => 'nullable|array',
        ]);
        
        $produk = Produk::findOrFail($request->produk_id);
        
        $produk->sedang_restock = true;
        $produk->jumlah_dipesan = $request->jumlah;
        
        if ($request->filled('jumlah_per_ukuran')) {
            $produk->jumlah_per_ukuran = $request->jumlah_per_ukuran;
        }
        
        $produk->save();
        
        return response()->json([
            'success' => true,
            'message' => 'Restock berhasil dicatat',
        ]);
    }
    
    // POST /rekomendasi-stok/konfirmasi-tiba
    public function konfirmasiTiba(Request $request)
    {
        $request->validate([
            'produk_id' => 'required|exists:produk,produk_id',
            'jumlah'    => 'required|integer|min:1',
        ]);

        $produk = Produk::findOrFail($request->produk_id);

        $jumlahTambah = $produk->jumlah_dipesan ?? $request->jumlah;
        $perUkuran    = $produk->jumlah_per_ukuran;

        if (is_array($perUkuran) && !empty($perUkuran) && isset($perUkuran[0])) {
            $normalized = [];
            foreach ($perUkuran as $entry) {
                if (isset($entry['size']) && isset($entry['jumlah'])) {
                    $normalized[$entry['size']] = (int) $entry['jumlah'];
                }
            }
            $perUkuran = $normalized;
        }

        $ukuranStok = $produk->ukuran_stok;
        if (is_string($ukuranStok)) {
            $ukuranStok = json_decode($ukuranStok, true);
        }

        if (is_array($ukuranStok) && !empty($ukuranStok)) {
            if (is_array($perUkuran) && !empty($perUkuran)) {
                foreach ($ukuranStok as &$uk) {
                    $size = $uk['size'];
                    if (isset($perUkuran[$size])) {
                        $uk['stock'] += (int) $perUkuran[$size];
                    }
                }
            } else {
                $ukuranStok[0]['stock'] += $jumlahTambah;
            }

            $produk->ukuran_stok = $ukuranStok;
            $totalStok = array_sum(array_column($ukuranStok, 'stock'));
            $produk->stok = $totalStok;
        } else {
            $produk->stok += $jumlahTambah;
        }

        $produk->sedang_restock    = false;
        $produk->jumlah_dipesan    = null;
        $produk->jumlah_per_ukuran = null;
        $produk->save();

        return response()->json([
            'success'    => true,
            'message'    => 'Stok berhasil diperbarui',
            'stok_baru'  => $produk->stok,
            'ukuran_stok' => $produk->ukuran_stok,
        ]);
    }
}