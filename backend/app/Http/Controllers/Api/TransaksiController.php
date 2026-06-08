<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaksi;
use App\Models\DetailTransaksi;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;

class TransaksiController extends Controller
{
    // GET /api/transaksi
    public function index(Request $request)
    {
        $user = $request->user();
        $transaksi = Transaksi::where('penjual_id', $user->penjual_id)
            ->with('detailTransaksi.produk.gambarProduk')
            ->orderBy('tanggal_transaksi', 'desc')
            ->get();
        
        return response()->json([
            'success' => true,
            'data' => $transaksi->map(function($item) {
                return [
                    'transaksi_id' => $item->transaksi_id,
                    'nomor_invoice' => $item->nomor_invoice,
                    'total' => $item->total,
                    'status' => $item->status,
                    'tanggal_transaksi' => $item->tanggal_transaksi,
                    'items' => $item->detailTransaksi->sum('jumlah'),
                ];
            }),
        ]);
    }
    
    // GET /api/transaksi/{id}
    public function show($id)
    {
        $transaksi = Transaksi::with('detailTransaksi.produk.gambarProduk')->findOrFail($id);
        
        return response()->json([
            'success' => true,
            'data' => [
                'transaksi_id' => $transaksi->transaksi_id,
                'nomor_invoice' => $transaksi->nomor_invoice,
                'total' => $transaksi->total,
                'status' => $transaksi->status,
                'tanggal_transaksi' => $transaksi->tanggal_transaksi,
                'detail' => $transaksi->detailTransaksi->map(function($detail) {
                    return [
                        'produk_id' => $detail->produk_id,
                        'nama_produk' => $detail->produk->nama_produk,
                        'ukuran' => $detail->ukuran,
                        'jumlah' => $detail->jumlah,
                        'harga' => $detail->harga_saat_transaksi,
                        'subtotal' => $detail->jumlah * $detail->harga_saat_transaksi,
                        'gambar' => $detail->produk->gambarProduk->first()->gambar ?? null,
                    ];
                }),
            ],
        ]);
    }
    
    // POST /api/transaksi
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'items' => 'required|array|min:1',
            'items.*.produk_id' => 'required|exists:produk,produk_id',
            'items.*.jumlah' => 'required|integer|min:1',
            'items.*.ukuran' => 'nullable|string',
        ]);
        
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        
        $user = $request->user();
        
        DB::beginTransaction();
        
        try {
            $total = 0;
            $detailData = [];
            
            foreach ($request->items as $item) {
                $produk = Produk::findOrFail($item['produk_id']);
                $ukuranDipilih = $item['ukuran'] ?? null;
                $jumlahBeli = $item['jumlah'];
                $ukuranStok = $produk->ukuran_stok;
                if (is_string($ukuranStok)) {
                    $ukuranStok = json_decode($ukuranStok, true);
                }
                
                if (!empty($ukuranStok) && is_array($ukuranStok) && count($ukuranStok) > 0) {
                    if (!$ukuranDipilih) {
                        throw new \Exception("Silakan pilih ukuran untuk produk {$produk->nama_produk}");
                    }
                
                // Cari ukuran dipilih
                $indexUkuran = null;
                foreach ($ukuranStok as $idx => $us) {
                    if ($us['size'] == $ukuranDipilih) {
                        $indexUkuran = $idx;
                        break;
                    }
                }
                
                if ($indexUkuran === null) {
                    throw new \Exception("Ukuran {$ukuranDipilih} tidak tersedia untuk produk {$produk->nama_produk}");
                }
                
                // Cek stok ukuran
                if ($ukuranStok[$indexUkuran]['stock'] < $jumlahBeli) {
                    throw new \Exception("Stok ukuran {$ukuranDipilih} untuk produk {$produk->nama_produk} tidak mencukupi (tersisa {$ukuranStok[$indexUkuran]['stock']})");
                }
                
                // Kurangi stok ukuran
                $ukuranStok[$indexUkuran]['stock'] -= $jumlahBeli;
                $produk->ukuran_stok = $ukuranStok;
                $produk->save();
                
                // Update stok total
                $produk->stok -= $jumlahBeli;
                $produk->save();
                
                } else {
                    if ($produk->stok < $jumlahBeli) {
                        throw new \Exception("Stok produk {$produk->nama_produk} tidak mencukupi (tersisa {$produk->stok})");
                    }
                    $produk->stok -= $jumlahBeli;
                    $produk->save();
                }
                
                $subtotal = $produk->harga * $jumlahBeli;
                $total += $subtotal;
                
                $detailData[] = [
                    'produk_id' => $produk->produk_id,
                    'ukuran' => $ukuranDipilih,
                    'jumlah' => $jumlahBeli,
                    'harga_saat_transaksi' => $produk->harga,
                ];
            }
            
            $nomorInvoice = 'INV-' . date('Ymd') . '-' . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);
            
            $transaksi = Transaksi::create([
                'nomor_invoice' => $nomorInvoice,
                'penjual_id' => $user->penjual_id,
                'total' => $total,
                'status' => 'selesai',
                'tanggal_transaksi' => now(),
            ]);
            
            foreach ($detailData as $detail) {
                DetailTransaksi::create([
                    'transaksi_id' => $transaksi->transaksi_id,
                    'produk_id' => $detail['produk_id'],
                    'ukuran' => $detail['ukuran'],
                    'jumlah' => $detail['jumlah'],
                    'harga_saat_transaksi' => $detail['harga_saat_transaksi'],
                ]);
            }
            
            DB::commit();
            
            return response()->json([
                'success' => true,
                'message' => 'Transaksi berhasil disimpan',
                'data' => $transaksi->load('detailTransaksi.produk'),
            ], 201);
            
            } catch (\Exception $e) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => $e->getMessage(),
            ],  400);
        }
    }
}
