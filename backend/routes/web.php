<?php

use Illuminate\Support\Facades\File;
use Illuminate\Support\Facades\Response;

Route::get('/gambar/{filename}', function ($filename) {

    $path = storage_path('app/public/images/' . $filename);

    if (!File::exists($path)) {
        abort(404);
    }

    $file = File::get($path);
    $type = File::mimeType($path);

    return Response::make($file, 200, [
        'Content-Type' => $type,
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET',
        'Access-Control-Allow-Headers' => '*',
    ]);
});
