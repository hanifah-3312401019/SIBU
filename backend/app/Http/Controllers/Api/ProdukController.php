<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use App\Models\Kategori;
use App\Models\GambarProduk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class ProdukController extends Controller
{
    //  PUBLIK – untuk halaman pembeli (tanpa auth)
 
    // GET /api/produk-publik
    public function indexPembeli(Request $request)
    {
        $query = Produk::with('kategori', 'gambarProduk');
 
        // Filter kategori
        if ($request->filled('kategori_id')) {
            $query->where('kategori_id', $request->kategori_id);
        }
 
        // Search nama produk
        if ($request->filled('search')) {
            $query->where('nama_produk', 'like', '%' . $request->search . '%');
        }
 
        $produk = $query->orderBy('created_at', 'desc')->get();
 
        $produk = $produk->map(fn($item) => $this->formatProdukPembeli($item));
 
        return response()->json(['success' => true, 'data' => $produk]);
    }
 
    // GET /api/produk-publik/{id}
    public function showPembeli($id)
    {
        $item = Produk::with('kategori', 'gambarProduk', 'penjual')->findOrFail($id);
 
        return response()->json([
            'success' => true,
            'data' => $this->formatProdukPembeli($item, withPenjual: true),
        ]);
    }
 
    // GET /api/rekomendasi
    public function rekomendasi(Request $request)
    {
        $tipe  = $request->get('tipe', 'terbaru');
        $limit = (int) $request->get('limit', 8);
        $limit = min($limit, 20);
 
        $query = Produk::with('kategori', 'gambarProduk')->where('stok', '>', 0);
 
        switch ($tipe) {
            // Paling banyak terjual di kategori tertentu
            case 'kategori':
                if ($request->filled('kategori_id')) {
                    $query->where('kategori_id', $request->kategori_id);
                }
                // Join detail_transaksi, urutkan berdasarkan total jumlah terjual
                $query->leftJoin('detail_transaksi', 'produk.produk_id', '=', 'detail_transaksi.produk_id')
                      ->selectRaw('produk.*, COALESCE(SUM(detail_transaksi.jumlah), 0) as total_terjual')
                      ->groupBy('produk.produk_id')
                      ->orderBy('total_terjual', 'desc');
                break;
 
            case 'harga_terendah':
                $query->orderBy('harga', 'asc');
                break;
 
            case 'terbaru':
            default:
                $query->orderBy('created_at', 'desc');
                break;
        }
 
        $produk = $query->limit($limit)->get()
            ->map(fn($item) => $this->formatProdukPembeli($item));
 
        return response()->json([
            'success' => true,
            'tipe'    => $tipe,
            'data'    => $produk,
        ]);
    }
 
    // Helper: format data produk untuk pembeli
    private function formatProdukPembeli(Produk $item, bool $withPenjual = false): array
    {
        $ukuranStok = $item->ukuran_stok;
        if (is_string($ukuranStok)) {
            $ukuranStok = json_decode($ukuranStok, true);
        }
        if (!is_array($ukuranStok)) {
            $ukuranStok = [];
        }
 
        $data = [
            'produk_id'   => $item->produk_id,
            'nama_produk' => $item->nama_produk ?? '',
            'deskripsi'   => $item->deskripsi ?? '',
            'harga'       => (int) ($item->harga ?? 0),
            'stok'        => (int) ($item->stok ?? 0),
            'min_stok'    => (int) ($item->min_stok ?? 10),
            'kategori_id' => $item->kategori_id,
            'kategori'    => $item->kategori ? $item->kategori->nama_kategori : '',
            'ukuran_stok' => $ukuranStok,
            'gambar'      => $item->gambarProduk->isNotEmpty()
                                ? $item->gambarProduk->first()->gambar
                                : '',
            'gambar_list' => $item->gambarProduk->map(fn($g) => $g->gambar)->toArray(),
            'size_chart'  => $item->size_chart ?? '',
            'created_at'  => $item->created_at,
            'updated_at'  => $item->updated_at,
        ];
 
        if ($withPenjual && $item->penjual) {
            $data['no_wa'] = $item->penjual->no_telepon ?? '';
            $data['nama_toko'] = $item->penjual->nama_toko ?? '';
        }
 
        return $data;
    }
    
    // GET /api/kategori
    public function getKategori()
    {
        $kategori = Kategori::all();
        return response()->json(['success' => true, 'data' => $kategori]);
    }
    
    // GET /api/produk
    public function index(Request $request)
    {
        $user = $request->user();
        $produk = Produk::where('penjual_id', $user->penjual_id)->with('kategori', 'gambarProduk')->get();
        
        $produk = $produk->map(function($item) {
            $ukuranStok = $item->ukuran_stok;
            if (is_string($ukuranStok)) {
                $ukuranStok = json_decode($ukuranStok, true);
            }
            if (!is_array($ukuranStok)) {
                $ukuranStok = [];
            }
            
            return [
                'produk_id' => $item->produk_id,
                'nama_produk' => $item->nama_produk ?? '',
                'deskripsi' => $item->deskripsi ?? '',
                'harga' => (int)($item->harga ?? 0),
                'stok' => (int)($item->stok ?? 0),
                'min_stok' => (int)($item->min_stok ?? 10),
                'kategori_id' => $item->kategori_id,
                'kategori' => $item->kategori ? $item->kategori->nama_kategori : '',
                'ukuran_stok' => $ukuranStok,
                'gambar' => $item->gambarProduk->isNotEmpty() ? $item->gambarProduk->first()->gambar : '',
                'gambar_list' => $item->gambarProduk->map(fn($g) => $g->gambar)->toArray(),
                'size_chart' => $item->size_chart ?? '',
                'created_at' => $item->created_at,
                'updated_at' => $item->updated_at,
            ];
        });
        
        return response()->json(['success' => true, 'data' => $produk]);
    }
    
    // POST /api/produk (Tambah)
    public function store(Request $request)
    {
        \Log::info('Store produk called', $request->all());
        
        $validator = Validator::make($request->all(), [
            'nama_produk' => 'required|string|max:200',
            'harga' => 'required|integer|min:0',
            'kategori_id' => 'required|exists:kategori,kategori_id',
            'ukuran_stok' => 'required',
            'gambar' => 'required|array|min:1|max:5',
            'gambar.*' => 'file|image|mimes:jpeg,png,jpg|max:2048',
        ]);
        
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        
        $user = $request->user();
        
        // Handle ukuran_stok
        $ukuranStok = $request->ukuran_stok;
        if (is_string($ukuranStok)) {
            $ukuranStok = json_decode($ukuranStok, true);
        }
        if (!is_array($ukuranStok)) {
            $ukuranStok = [];
        }
        
        // Handle upload size chart
        $sizeChartPath = null;
        if ($request->hasFile('size_chart')) {
            $file = $request->file('size_chart');
            $filename = 'sizechart_' . time() . '_' . $file->getClientOriginalName();
            $sizeChartPath = $file->storeAs('size_charts', $filename, 'public');
        }
        
        // Buat produk
        $produk = Produk::create([
            'penjual_id' => $user->penjual_id,
            'kategori_id' => $request->kategori_id,
            'nama_produk' => $request->nama_produk,
            'deskripsi' => $request->deskripsi,
            'harga' => $request->harga,
            'stok' => $request->stok ?? 0,
            'min_stok' => $request->min_stok ?? 10,
            'ukuran_stok' => $ukuranStok,
            'size_chart' => $sizeChartPath,
        ]);
        
        // Upload multiple gambar
        if ($request->hasFile('gambar')) {
            foreach ($request->file('gambar') as $index => $file) {
                $filename = time() . '_' . $index . '_' . $file->getClientOriginalName();
                $gambarPath = $file->storeAs('images', $filename, 'public');
                
                GambarProduk::create([
                    'produk_id' => $produk->produk_id,
                    'gambar' => $gambarPath,
                    'urutan' => $index,
                ]);
            }
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil ditambahkan',
            'data' => $produk->load('gambarProduk')
        ], 201);
    }
    
    // PUT /api/produk/{id} (Edit)
    public function update(Request $request, $id)
    {
        \Log::info('Update produk ID: ' . $id, $request->all());
        
        $produk = Produk::findOrFail($id);
        
        $validator = Validator::make($request->all(), [
            'nama_produk' => 'string|max:200',
            'harga' => 'integer|min:0',
            'kategori_id' => 'exists:kategori,kategori_id',
            'gambar.*' => 'file|image|mimes:jpeg,png,jpg|max:2048',
        ]);
        
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        
        $updateData = [
            'nama_produk' => $request->nama_produk ?? $produk->nama_produk,
            'deskripsi' => $request->deskripsi ?? $produk->deskripsi,
            'harga' => $request->harga ?? $produk->harga,
            'stok' => $request->stok ?? $produk->stok,
            'min_stok' => $request->min_stok ?? $produk->min_stok,
            'kategori_id' => $request->kategori_id ?? $produk->kategori_id,
        ];
        
        // Handle ukuran_stok
        if ($request->has('ukuran_stok')) {
            $ukuranStok = $request->ukuran_stok;
            while (is_string($ukuranStok)) {
                $ukuranStok = json_decode($ukuranStok, true);
            }
            if (is_array($ukuranStok)) {
                $updateData['ukuran_stok'] = $ukuranStok;
            }
        }
        
        // Handle upload size chart
        if ($request->hasFile('size_chart')) {
            if ($produk->size_chart && Storage::disk('public')->exists($produk->size_chart)) {
                Storage::disk('public')->delete($produk->size_chart);
            }
            $file = $request->file('size_chart');
            $filename = 'sizechart_' . time() . '_' . $file->getClientOriginalName();
            $updateData['size_chart'] = $file->storeAs('size_charts', $filename, 'public');
        } elseif ($request->has('delete_size_chart') && $request->delete_size_chart == 'true') {
            if ($produk->size_chart && Storage::disk('public')->exists($produk->size_chart)) {
                Storage::disk('public')->delete($produk->size_chart);
            }
            $updateData['size_chart'] = null;
        }
        
        $produk->update($updateData);
        
        // Handle multiple gambar upload
        if ($request->hasFile('gambar')) {
            foreach ($request->file('gambar') as $index => $file) {
                $filename = time() . '_' . $index . '_' . $file->getClientOriginalName();
                $gambarPath = $file->storeAs('images', $filename, 'public');
                
                GambarProduk::create([
                    'produk_id' => $produk->produk_id,
                    'gambar' => $gambarPath,
                    'urutan' => $produk->gambarProduk()->count() + $index,
                ]);
            }
        }
        
        // Handle hapus gambar berdasarkan ID
        if ($request->has('delete_gambar_ids')) {
            $deleteIds = explode(',', $request->delete_gambar_ids);
            foreach ($deleteIds as $gambarId) {
                $gambar = GambarProduk::find($gambarId);
                if ($gambar && $gambar->produk_id == $produk->produk_id) {
                    if (Storage::disk('public')->exists($gambar->gambar)) {
                        Storage::disk('public')->delete($gambar->gambar);
                    }
                    $gambar->delete();
                }
            }
        }
        
        // Update urutan gambar
        if ($request->has('gambar_urutan')) {
            foreach ($request->gambar_urutan as $gambarId => $urutan) {
                GambarProduk::where('gambar_id', $gambarId)
                    ->where('produk_id', $produk->produk_id)
                    ->update(['urutan' => $urutan]);
            }
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil diupdate',
            'data' => $produk->load('gambarProduk')
        ]);
    }
    
    // DELETE /api/produk/{id}
    public function destroy($id)
    {
        $produk = Produk::findOrFail($id);
        
        // Hapus semua gambar produk
        foreach ($produk->gambarProduk as $gambar) {
            if (Storage::disk('public')->exists($gambar->gambar)) {
                Storage::disk('public')->delete($gambar->gambar);
            }
        }
        
        if ($produk->size_chart && Storage::disk('public')->exists($produk->size_chart)) {
            Storage::disk('public')->delete($produk->size_chart);
        }
        
        $produk->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil dihapus'
        ]);
    }
}
