<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;

class ProdukController extends Controller
{
    // GET /api/produk
    public function index(Request $request)
    {
        $user = $request->user();
        $produk = Produk::where('penjual_id', $user->penjual_id)->get();
        
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
                'kategori' => $item->kategori ?? '',
                'ukuran_stok' => $ukuranStok,
                'gambar' => $item->gambar ?? '',
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
            'kategori' => 'required|string',
            'ukuran_stok' => 'required',
        ]);
        
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
        
        $user = $request->user();
        
        // Handle ukuran_stok (decode dari JSON string)
        $ukuranStok = $request->ukuran_stok;
        if (is_string($ukuranStok)) {
            $ukuranStok = json_decode($ukuranStok, true);
        }
        if (!is_array($ukuranStok)) {
            $ukuranStok = [];
        }
        
        // Handle upload gambar
        $gambarPath = null;
        if ($request->hasFile('gambar')) {
            $file = $request->file('gambar');
            $filename = time() . '_' . $file->getClientOriginalName();
            $gambarPath = $file->storeAs('images', $filename, 'public');
        }
        
        $produk = Produk::create([
            'penjual_id' => $user->penjual_id,
            'nama_produk' => $request->nama_produk,
            'deskripsi' => $request->deskripsi,
            'harga' => $request->harga,
            'stok' => $request->stok ?? 0,
            'min_stok' => $request->min_stok ?? 10,
            'kategori' => $request->kategori,
            'ukuran_stok' => $ukuranStok,
            'gambar' => $gambarPath,
        ]);
        
        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil ditambahkan',
            'data' => $produk
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
            'kategori' => $request->kategori ?? $produk->kategori,
        ];
        
        // Handle ukuran_stok (decode dari JSON string)
        if ($request->has('ukuran_stok')) {
            $ukuranStok = $request->ukuran_stok;
        
            // Decode sampai array
            while (is_string($ukuranStok)) {
                $ukuranStok = json_decode($ukuranStok, true);
            }
        
            if (is_array($ukuranStok)) {
                $updateData['ukuran_stok'] = $ukuranStok;
                \Log::info('Ukuran stok saved: ', $updateData['ukuran_stok']);
            }
        }
        
        // Handle upload gambar baru
        if ($request->hasFile('gambar')) {
            if ($produk->gambar && Storage::disk('public')->exists($produk->gambar)) {
                Storage::disk('public')->delete($produk->gambar);
            }
            $file = $request->file('gambar');
            $filename = time() . '_' . $file->getClientOriginalName();
            $updateData['gambar'] = $file->storeAs('images', $filename, 'public');
        }
        
        $produk->update($updateData);
        
        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil diupdate',
            'data' => $produk
        ]);
    }
    
    // DELETE /api/produk/{id}
    public function destroy($id)
    {
        $produk = Produk::findOrFail($id);
        if ($produk->gambar && Storage::disk('public')->exists($produk->gambar)) {
            Storage::disk('public')->delete($produk->gambar);
        }
        $produk->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Produk berhasil dihapus'
        ]);
    }
}