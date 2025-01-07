<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DetailTransaksi;
use App\Models\LaporanKeuangan;
use App\Models\LogStok;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class LogStokController extends Controller
{

    /**
     * Get
     */
    public function show()
    {
        $data = LogStok::orderBy('created_at', 'desc')->get();
        $data->load('produk');
        return returnJson($data);
    }
    public function index()
    {
        $data = LogStok::get();
        return returnJson($data);
    }

    /**
     * Create
     */
    public function create(Request $request)
    {
        // validate the request...
        $request->validate([
            'produk_id' => 'required',
            'jumlah' => 'required|numeric',
            'stok_sebelum' => 'required|numeric',
            'stok_sesudah' => 'required|numeric',
            'keterangan' => 'required',
            'jenis_perubahan' => 'required',
            'petugas_id' => 'required',
        ]);

        // store the request...
        $data = new LogStok;
        $data->id = Str::uuid()->toString();
        $data->produk_id = $request->produk_id;
        $data->jumlah = $request->jumlah;
        $data->stok_sebelum = $request->stok_sebelum;
        $data->stok_sesudah = $request->stok_sesudah;
        $data->keterangan = $request->keterangan;
        $data->petugas_id = $request->petugas_id;
        $data->jenis_perubahan = $request->jenis_perubahan;
        $data->save();

        $produk = Produk::findOrFail($request->produk_id);
        if ($produk) {
            $produk->stok = $request->stok_sesudah;
            $produk->save();

            // store to laporan keuangan
            $stok_sesudah = $request->stok_sesudah;
            $stok_sebelum = $request->stok_sebelum;
            if ($stok_sebelum != $stok_sesudah) {
                $selisih = abs($stok_sesudah - $stok_sebelum);
                $no_transaksi = 'SOP-' . date('Ymd-hhmm');
                $laporanKeuangan = new LaporanKeuangan;
                $laporanKeuangan->id = Str::uuid()->toString();
                $laporanKeuangan->tanggal = date('Y-m-d');
                $laporanKeuangan->jenis = $stok_sesudah < $stok_sebelum ? 'pengeluaran' : 'pemasukan';
                $laporanKeuangan->kategori = 'Stok Opname';
                $laporanKeuangan->jumlah = $selisih * $produk->harga_jual;
                $laporanKeuangan->keterangan = $laporanKeuangan->kategori . ': ' . $no_transaksi;
                $laporanKeuangan->bukti_transaksi = $no_transaksi;
                $laporanKeuangan->created_by = $data->petugas_id;
                $laporanKeuangan->save();
            }
        }

        return returnJson($data, 201);
    }

    /**
     * Update
     */
    public function update(Request $request)
    {
        return returnJsonNotAllowed();
    }

    /**
     * Delete
     */
    public function destroy($id)
    {
        return returnJsonNotAllowed();
    }
}
