<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Periode;
use Illuminate\Http\Request;

class PeriodeController extends Controller
{
    public function index()
    {
        $periode = Periode::orderBy('tanggal_mulai', 'desc')->get();
        
        return response()->json([
            'success' => true, 
            'data' => $periode->map(function($p) {
                return [
                    'periode_id' => $p->periode_id,
                    'nama_periode' => $p->nama_periode,
                    'tanggal_mulai' => $p->tanggal_mulai->format('Y-m-d'),
                    'tanggal_selesai' => $p->tanggal_selesai->format('Y-m-d'),
                    'catatan' => $p->catatan,
                    'multiplier' => $p->multiplier ?? 1.0,
                    'created_at' => $p->created_at,
                    'updated_at' => $p->updated_at,
                ];
            }),
        ]);
    }

    public function show($id)
    {
        $p = Periode::find($id);
        
        if (!$p) {
            return response()->json([
                'success' => false, 
                'message' => 'Periode tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true, 
            'data' => [
                'periode_id' => $p->periode_id,
                'nama_periode' => $p->nama_periode,
                'tanggal_mulai' => $p->tanggal_mulai->format('Y-m-d'),
                'tanggal_selesai' => $p->tanggal_selesai->format('Y-m-d'),
                'catatan' => $p->catatan,
                'multiplier' => $p->multiplier ?? 1.0, 
                'created_at' => $p->created_at,
                'updated_at' => $p->updated_at,
            ],
        ]);
    }
    
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_periode' => 'required|string|max:100',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date|after_or_equal:tanggal_mulai',
            'catatan' => 'nullable|string',
            'multiplier' => 'nullable|numeric|min:0.5|max:10',
        ]);
        
        $periode = Periode::create($validated);
        
        return response()->json([
            'success' => true, 
            'data' => [
                'periode_id' => $periode->periode_id,
                'nama_periode' => $periode->nama_periode,
                'tanggal_mulai' => $periode->tanggal_mulai->format('Y-m-d'),
                'tanggal_selesai' => $periode->tanggal_selesai->format('Y-m-d'),
                'catatan' => $periode->catatan,
                'multiplier' => $periode->multiplier ?? 1.0,
            ],
        ], 201);
    }
    
    public function update(Request $request, $id)
    {
        $periode = Periode::findOrFail($id);
        
        $validated = $request->validate([
            'nama_periode' => 'sometimes|string|max:100',
            'tanggal_mulai' => 'sometimes|date',
            'tanggal_selesai' => 'sometimes|date|after_or_equal:tanggal_mulai',
            'catatan' => 'nullable|string',
            'multiplier' => 'nullable|numeric|min:0.5|max:10',
        ]);
        
        $periode->update($validated);
        
        return response()->json([
            'success' => true, 
            'data' => [
                'periode_id' => $periode->periode_id,
                'nama_periode' => $periode->nama_periode,
                'tanggal_mulai' => $periode->tanggal_mulai->format('Y-m-d'),
                'tanggal_selesai' => $periode->tanggal_selesai->format('Y-m-d'),
                'catatan' => $periode->catatan,
                'multiplier' => $periode->multiplier ?? 1.0,
            ],
        ]);
    }
    
    public function destroy($id)
    {
        $periode = Periode::findOrFail($id);
        $periode->delete();
        return response()->json(['success' => true, 'message' => 'Periode dihapus']);
    }
}