<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\Penjual;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Laravel\Sanctum\HasApiTokens;

class LoginController extends Controller
{
    public function login(Request $request)
    {
        // Validasi input
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors' => $validator->errors()
            ], 422);
        }

        // Cari penjual berdasarkan email
        $penjual = Penjual::where('email', $request->email)->first();

        if (!$penjual) {
            return response()->json([
                'success' => false,
                'message' => 'Email tidak ditemukan'
            ], 401);
        }

        // Verifikasi password
        if (!Hash::check($request->password, $penjual->kata_sandi)) {
            return response()->json([
                'success' => false,
                'message' => 'Password salah'
            ], 401);
        }

        // Buat token dengan Sanctum
        $token = $penjual->createToken('auth_token')->plainTextToken;

        // Login berhasil
        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'penjual_id' => $penjual->penjual_id,
                'nama' => $penjual->nama,
                'email' => $penjual->email,
                'no_telepon' => $penjual->no_telepon,
                'nama_toko' => $penjual->nama_toko,
            ],
            'token' => $token
        ], 200);
    }

    public function logout(Request $request)
    {
        // Hapus token yang sedang digunakan
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ], 200);
    }

    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => $request->user()
        ], 200);
    }

    // PUT /api/me — update nama & no_telepon
    public function updateProfil(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'nama'       => 'required|string|max:100',
            'no_telepon' => 'required|string|max:20',
        ]);
 
        if ($validator->fails()) {
            return response()->json(['errors' => $validator->errors()], 422);
        }
 
        $user = $request->user();
        $user->update([
            'nama'       => $request->nama,
            'no_telepon' => $request->no_telepon,
        ]);
 
        return response()->json([
            'success' => true,
            'message' => 'Profil berhasil diperbarui',
            'data' => [
                'nama'       => $user->nama,
                'email'      => $user->email,
                'no_telepon' => $user->no_telepon,
                'nama_toko'  => $user->nama_toko,
            ],
        ]);
    }
}