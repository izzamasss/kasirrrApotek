<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Kategori;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class KategoriController extends Controller
{
    /**
     * Get
     */
    public function show(Request $request)
    {
        $search = $request->input('search');
        $data = new Kategori;
        if ($search) {
            $data = $data->where('nama', 'like', '%' . $search . '%')->orWhere('deskripsi', 'like', '%' . $search . '%');
        }
        $data = $data->orderBy('nama')->get();
        return returnJson($data);
    }

    /**
     * Create
     */
    public function create(Request $request)
    {
        // validate the request...
        $request->validate([
            'nama' => 'required',
            'deskripsi' => 'required',
        ]);

        // store the request...
        $data = new Kategori;
        $data->id = Str::uuid()->toString();
        $data->nama = $request->nama;
        $data->deskripsi = $request->deskripsi;
        $data->is_aktif = true;
        $data->save();

        return returnJson($data, 201);
    }

    /**
     * Update
     */
    public function update(Request $request)
    {
        $request->validate([
            'nama' => 'required',
            'deskripsi' => 'required',
        ]);

        $data = Kategori::findOrFail($request->id);
        $data->nama = $request->nama;
        $data->deskripsi = $request->deskripsi;
        $data->save();
        return returnJson($data);
    }

    /**
     * Delete
     */
    public function destroy($id)
    {
        $data = Kategori::findOrFail($id);
        $produks = Produk::where('kategori_id', '=', $id)->get();
        foreach ($produks as $ou) {
            $ou->delete();
        }
        $data->delete();
        return returnJson('Success');
    }
}
