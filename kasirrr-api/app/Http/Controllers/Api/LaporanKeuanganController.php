<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DetailTransaksi;
use App\Models\LaporanKeuangan;
use App\Models\Produk;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use stdClass;

class LaporanKeuanganController extends Controller
{

    /**
     * Get
     */
    public function show(Request $request)
    {
        $date = $request->input('date');
        $periode = $request->input('periode');

        if ($date && $periode) {
            $db = LaporanKeuangan::leftJoin('pengguna', 'laporan_keuangan.created_by', '=', 'pengguna.id');

            $column = 'laporan_keuangan.created_at';
            $conditionTime = [];

            if ($periode == 'Harian') {
                $conditionTime = [$date . ' 00:00:00', $date . ' 23:59:59'];
            } else if ($periode == 'Bulanan') {
                $month = date('m', strtotime($date));
                $year = date('Y', strtotime($date));

                $start = $year . '-' . $month . '-01 00:00:01';
                $monthEnd = $month;
                $yearEnd = $year;
                if ($month == 12) {
                    $monthEnd = 1;
                    $yearEnd = $year + 1;
                } else {
                    $monthEnd += 1;
                }
                $end = $yearEnd . '-' . $monthEnd . '-01 00:00:00';
                $conditionTime = [$start, $end];
            } else {
                $year = date('Y', strtotime($date));
                $conditionTime = [$year . '-01-01 00:00:00', $year . '-12-31 23:59:59'];
            }
            $reports = $db->whereBetween($column, $conditionTime);

            $reports = $reports->get([
                'laporan_keuangan.*',
                'pengguna.nama as petugas'
            ]);
            $data = new stdClass;
            $data->total_pemasukan = (int) $this->calculateJumlah($conditionTime, 'pemasukan');
            $data->total_pengeluaran = (int) $this->calculateJumlah($conditionTime, 'pengeluaran');
            $data->laporan_keuangan = $reports;

            return returnJson($data);
        }

        return returnJsonFailed('Failed Get Data Product', []);
    }

    public function calculateJumlah($conditionTime, $jenis)
    {
        return LaporanKeuangan::whereBetween('created_at', $conditionTime)
            ->where('jenis', $jenis)
            ->sum('jumlah');
    }

    /**
     * Create
     */
    public function create(Request $request)
    {
        return returnJsonNotAllowed();
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
