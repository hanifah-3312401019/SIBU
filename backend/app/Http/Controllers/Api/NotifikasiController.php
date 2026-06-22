<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Notifikasi;
use Illuminate\Http\Request;

class NotifikasiController extends Controller
{
    // GET /api/notifikasi
    public function index(Request $request)
    {
        $user = $request->user();

        $notifikasi = Notifikasi::where('penjual_id', $user->penjual_id)
            ->with('produk:produk_id,nama_produk')
            ->orderBy('waktu_notifikasi', 'desc')
            ->limit(50)
            ->get()
            ->map(function ($item) {
                return [
                    'notifikasi_id'    => $item->notifikasi_id,
                    'produk_id'        => $item->produk_id,
                    'nama_produk'      => $item->produk?->nama_produk,
                    'pesan'            => $item->pesan,
                    'sudah_dibaca'     => $item->sudah_dibaca,
                    'waktu_notifikasi' => $item->waktu_notifikasi,
                ];
            });

        $belumDibaca = Notifikasi::where('penjual_id', $user->penjual_id)
            ->where('sudah_dibaca', false)
            ->count();

        return response()->json([
            'success'      => true,
            'data'         => $notifikasi,
            'belum_dibaca' => $belumDibaca,
        ]);
    }

    // PUT /api/notifikasi — Tandai satu notifikasi dibaca
    public function tandaiBaca($id, Request $request)
    {
        $user = $request->user();

        $notif = Notifikasi::where('notifikasi_id', $id)
            ->where('penjual_id', $user->penjual_id)
            ->firstOrFail();

        $notif->update(['sudah_dibaca' => true]);

        return response()->json(['success' => true, 'message' => 'Notifikasi ditandai dibaca']);
    }

    // PUT /api/notifikasi/baca-semua
    public function tandaiSemuaBaca(Request $request)
    {
        $user = $request->user();

        Notifikasi::where('penjual_id', $user->penjual_id)
            ->where('sudah_dibaca', false)
            ->update(['sudah_dibaca' => true]);

        return response()->json(['success' => true, 'message' => 'Semua notifikasi ditandai dibaca']);
    }

    // DELETE /api/notifikasi/hapus-semua
    public function hapusSemuaNotifikasi(Request $request)
    {
        $user = $request->user();
 
        Notifikasi::where('penjual_id', $user->penjual_id)->delete();
 
        return response()->json(['success' => true, 'message' => 'Semua notifikasi berhasil dihapus']);
    }

    // POST /api/fcm-token
    public function saveFcmToken(Request $request)
    {
        $request->validate(['fcm_token' => 'required|string']);

        $user = $request->user();
        $user->update(['fcm_token' => $request->fcm_token]);

        return response()->json(['success' => true, 'message' => 'FCM token disimpan']);
    }
}