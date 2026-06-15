<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use App\Models\DetailTransaksi;
use App\Models\Periode;
use Illuminate\Http\Request;

class RekomendasiStokController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $periodeId = $request->get('periode_id');
        $hariCover = (int) $request->get('hari_cover', 21);

        $produk = Produk::where('penjual_id', $user->penjual_id)
            ->with('gambarProduk')
            ->get();

        $rekomendasi = [];

        foreach ($produk as $item) {
            // Produk sedang dalam proses restock
            if ($item->sedang_restock) {
                $rekomendasi[] = [
                    'id'             => $item->produk_id,
                    'nama'           => $item->nama_produk,
                    'badge'          => $periodeId
                        ? (Periode::find($periodeId)?->nama_periode ?? 'Periode Khusus')
                        : 'Normal',
                    'stok'           => $item->stok,
                    'ukuran_stok'    => $item->ukuran_stok ?? [],
                    'rataHari'       => 0,
                    'saranTambah'    => 0,
                    'status'         => 'sudah_dipesan',
                    'gambar'         => $item->gambarProduk->isNotEmpty()
                        ? $item->gambarProduk->first()->gambar
                        : null,
                    'jumlah_dipesan'     => $item->jumlah_dipesan,
                    'jumlah_per_ukuran'  => $item->jumlah_per_ukuran ?? null,
                ];
                continue;
            }

            // Hitung dari data transaksi
            $query = DetailTransaksi::where('produk_id', $item->produk_id);

            if ($periodeId) {
                $periode = Periode::find($periodeId);
                if ($periode) {
                    $query->whereBetween('created_at', [
                        $periode->tanggal_mulai,
                        $periode->tanggal_selesai,
                    ]);
                    $totalHari = $periode->tanggal_mulai->diffInDays($periode->tanggal_selesai) + 1;
                } else {
                    $totalHari = $hariCover;
                    $query->where('created_at', '>=', now()->subDays($hariCover));
                }
            } else {
                $totalHari = $hariCover;
                $query->where('created_at', '>=', now()->subDays($hariCover));
            }

            $totalTerjual = $query->sum('jumlah');

            // rataHari = total terjual / hari dalam periode
            $rataHari = $totalHari > 0 ? round($totalTerjual / $totalHari, 1) : 0;

            // saranTambah = (rataHari × hariCover) - stok saat ini
            $saranTambah = (int) round(($rataHari * $hariCover) - $item->stok);
            if ($saranTambah < 0) $saranTambah = 0;

            // Status berdasarkan perbandingan stok vs min_stok
            if ($item->stok <= $item->min_stok) {
                $status = 'perlu_restock';
            } elseif ($item->stok <= $item->min_stok * 2) {
                $status = 'perlu_diperhatikan';
            } else {
                $status = 'cukup';
            }

            $rekomendasi[] = [
                'id'             => $item->produk_id,
                'nama'           => $item->nama_produk,
                'badge'          => $periodeId
                    ? (Periode::find($periodeId)?->nama_periode ?? 'Periode Khusus')
                    : 'Normal',
                'stok'           => $item->stok,
                'ukuran_stok'    => $item->ukuran_stok ?? [],  // ← dikirim ke Flutter
                'rataHari'       => $rataHari,
                'saranTambah'    => $saranTambah,
                'status'         => $status,
                'gambar'         => $item->gambarProduk->isNotEmpty()
                    ? $item->gambarProduk->first()->gambar
                    : null,
                'jumlah_dipesan'    => null,
                'jumlah_per_ukuran' => null,
            ];
        }

        // Urutkan: produk paling butuh restock di atas
        usort($rekomendasi, function ($a, $b) {
            $prioritas = ['perlu_restock' => 0, 'sudah_dipesan' => 1, 'perlu_diperhatikan' => 2, 'cukup' => 3, 'telah_tiba' => 4];
            $pa = $prioritas[$a['status']] ?? 5;
            $pb = $prioritas[$b['status']] ?? 5;
            if ($pa !== $pb) return $pa - $pb;
            return $b['saranTambah'] - $a['saranTambah'];
        });

        return response()->json([
            'success'    => true,
            'data'       => $rekomendasi,
            'periode_id' => $periodeId,
            'hari_cover' => $hariCover,
        ]);
    }

    // POST /rekomendasi-stok/restock
    public function restock(Request $request)
    {
        $request->validate([
            'produk_id'               => 'required|exists:produk,produk_id',
            'jumlah'                  => 'required|integer|min:1',
            'jumlah_per_ukuran'       => 'nullable|array',
            'jumlah_per_ukuran.*.size'   => 'required_with:jumlah_per_ukuran|string',
            'jumlah_per_ukuran.*.jumlah' => 'required_with:jumlah_per_ukuran|integer|min:0',
        ]);

        $produk = Produk::findOrFail($request->produk_id);

        $produk->sedang_restock  = true;
        $produk->jumlah_dipesan  = $request->jumlah;

        // Simpan distribusi per ukuran jika dikirim
        if ($request->filled('jumlah_per_ukuran')) {
            $perUkuran = [];
            foreach ($request->jumlah_per_ukuran as $entry) {
                $perUkuran[$entry['size']] = (int) $entry['jumlah'];
            }
            $produk->jumlah_per_ukuran = $perUkuran;
        } else {
            $produk->jumlah_per_ukuran = null;
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

        // Update ukuran_stok per ukuran 
        $ukuranStok = $produk->ukuran_stok;
        if (is_string($ukuranStok)) {
            $ukuranStok = json_decode($ukuranStok, true);
        }

        if (is_array($ukuranStok) && !empty($ukuranStok)) {
            $perUkuran = $produk->jumlah_per_ukuran;
            if (is_string($perUkuran)) {
                $perUkuran = json_decode($perUkuran, true);
            }

            if (is_array($perUkuran) && !empty($perUkuran)) {
                foreach ($ukuranStok as &$uk) {
                    $size = $uk['size'];
                    if (isset($perUkuran[$size])) {
                        $uk['stock'] += (int) $perUkuran[$size];
                    }
                }
                unset($uk);
            } else {
                // Tidak ada distribusi → tambahkan merata ke ukuran pertama
                // atau bisa juga dibagi rata, tergantung kebutuhan bisnis.
                // Default: tambah ke ukuran pertama.
                $ukuranStok[0]['stock'] += $jumlahTambah;
            }

            $produk->ukuran_stok = $ukuranStok;
        }

        // Update stok total
        $produk->stok += $jumlahTambah;

        // Reset flag restock
        $produk->sedang_restock    = false;
        $produk->jumlah_dipesan    = null;
        $produk->jumlah_per_ukuran = null;

        $produk->save();

        return response()->json([
            'success'   => true,
            'message'   => 'Stok berhasil diperbarui',
            'stok_baru' => $produk->stok,
        ]);
    }
}