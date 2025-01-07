<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Produk;
use Illuminate\Support\Str;

class ProdukController extends Controller
{
    /**
     * Get
     */
    public function show(Request $request)
    {
        $search = $request->input('search');
        $data = new Produk;
        if ($search) {
            $data = $data->where('kode', 'like', '%' . $search . '%')
                ->orWhere('barcode', 'like', '%' . $search . '%')
                ->orWhere('nama', 'like', '%' . $search . '%')
                ->orWhere('deskripsi', 'like', '%' . $search . '%');
        }
        $data = $data->orderBy('nama')->get();
        $data->load('kategori');
        return returnJson($data);
    }

    /**
     * Create
     */
    public function create(Request $request)
    {
        // validate the request...
        $request->validate([
            'kode' => 'required',
            'barcode' => 'nullable',
            'nama' => 'required',
            'deskripsi' => 'nullable',
            'kategori_id' => 'required',
            'harga_beli' => 'required|numeric',
            'harga_jual' => 'required|numeric',
            'stok' => 'required|numeric',
        ]);

        // store the request...
        $data = new Produk;
        $data->id = Str::uuid()->toString();
        $data->kode = $request->kode;
        if ($request->barcode) $data->barcode = $request->barcode;
        $data->nama = $request->nama;
        if ($request->deskripsi) $data->deskripsi = $request->deskripsi;
        $data->kategori_id = $request->kategori_id;
        $data->harga_beli = $request->harga_beli;
        $data->harga_jual = $request->harga_jual;
        $data->stok = $request->stok;
        $data->is_aktif = true;
        $data->save();

        return returnJson($data, 201);
    }

    /**
     * Update
     */
    public function update(Request $request)
    {
        // validate the request...
        $request->validate([
            'kode' => 'required',
            'barcode' => 'nullable',
            'nama' => 'required',
            'deskripsi' => 'nullable',
            'kategori_id' => 'required',
            'harga_beli' => 'required|numeric',
            'harga_jual' => 'required|numeric',
            'stok' => 'required|numeric',
        ]);

        $data = Produk::findOrFail($request->id);
        $data->kode = $request->kode;
        if ($request->barcode) $data->barcode = $request->barcode;
        $data->nama = $request->nama;
        if ($request->deskripsi) $data->deskripsi = $request->deskripsi;
        $data->kategori_id = $request->kategori_id;
        $data->harga_beli = $request->harga_beli;
        $data->harga_jual = $request->harga_jual;
        $data->stok = $request->stok;

        $data->save();
        return returnJson($data, 200);
    }

    /**
     * Delete
     */
    public function destroy($id)
    {
        $data = Produk::findOrFail($id);
        $data->delete();
        return returnJson('Success');
    }
}
