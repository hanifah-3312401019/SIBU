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
        return response()->json(['success' => true, 'data' => $periode]);
    }

    public function show($id)
    {
        $periode = Periode::find($id);
        
        if (!$periode) {
            return response()->json([
                'success' => false, 
                'message' => 'Periode tidak ditemukan'
            ], 404);
        }
        
        return response()->json([
            'success' => true, 
            'data' => $periode
        ]);
    }
    
    public function store(Request $request)
    {
        $validated = $request->validate([
            'nama_periode' => 'required|string|max:100',
            'tanggal_mulai' => 'required|date',
            'tanggal_selesai' => 'required|date|after_or_equal:tanggal_mulai',
            'catatan' => 'nullable|string',
        ]);
        
        $periode = Periode::create($validated);
        return response()->json(['success' => true, 'data' => $periode], 201);
    }
    
    public function update(Request $request, $id)
    {
        $periode = Periode::findOrFail($id);
        
        $validated = $request->validate([
            'nama_periode' => 'sometimes|string|max:100',
            'tanggal_mulai' => 'sometimes|date',
            'tanggal_selesai' => 'sometimes|date|after_or_equal:tanggal_mulai',
            'catatan' => 'nullable|string',
        ]);
        
        $periode->update($validated);
        return response()->json(['success' => true, 'data' => $periode]);
    }
    
    public function destroy($id)
    {
        $periode = Periode::findOrFail($id);
        $periode->delete();
        return response()->json(['success' => true, 'message' => 'Periode dihapus']);
    }
}