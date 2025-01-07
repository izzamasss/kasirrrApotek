<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DetailTransaksi;
use App\Models\LaporanKeuangan;
use App\Models\LogStok;
use Illuminate\Http\Request;
use App\Models\Transaksi;
use Carbon\Month;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use PhpParser\Node\Expr\Cast\Object_;
use stdClass;

class TransaksiController extends Controller
{

    /**
     * Get
     */
    public function show()
    {
        $data = Transaksi::orderBy('nama')->get();
        // $data->load('kategori');
        return returnJson($data);
    }
    public function index(Request $request)
    {
        $startDate = $request->input('start_date');
        $endDate = $request->input('end_date');
        $outletId = $request->input('outlet_id');

        if ($startDate && $endDate && $outletId) {
            $orders = Transaksi::whereBetween('created_at', [$startDate . ' 00:00:00', $endDate . ' 23:59:59']);
            $orders = $orders->where('outlet_id', $outletId);
            $orders = $orders->get();
            return returnJson($orders);
        }

        return returnJsonFailed('Failed Get Data Product', []);
    }

    //save order
    public function saveOrder(Request $request)
    {
        //validate request
        $request->validate([
            'outlet_id' => 'required',
            'shift' => 'required',
            'payment_amount' => 'required',
            'sub_total' => 'required',
            'tax' => 'required',
            'discount' => 'required',
            'discount_amount' => 'required',
            'service_charge' => 'required',
            'total' => 'required',
            'payment_method' => 'required',
            'total_item' => 'required',
            'id_kasir' => 'required',
            'nama_kasir' => 'required',
            'transaction_time' => 'required',
            // 'order_items' => 'required'
        ]);

        //create order
        $order = Transaksi::create([
            'outlet_id' => $request->outlet_id,
            'shift' => $request->shift,
            'payment_amount' => $request->payment_amount,
            'sub_total' => $request->sub_total,
            'tax' => $request->tax,
            'discount' => $request->discount,
            'discount_amount' => $request->discount_amount,
            'service_charge' => $request->service_charge,
            'total' => $request->total,
            'payment_method' => $request->payment_method,
            'total_item' => $request->total_item,
            'id_kasir' => $request->id_kasir,
            'nama_kasir' => $request->nama_kasir,
            'transaction_time' => $request->transaction_time,
            'table_number' => $request->table_number,
            'customer_name' => $request->customer_name,
            'status' => $request->status,
            'is_dine_in' => $request->is_dine_in,
        ]);

        //create order items
        foreach ($request->order_items as $item) {
            DetailTransaksi::create([
                'order_id' => $order->id,
                'outlet_id' => $request->outlet_id,
                'product_id' => $item['product_id'],
                'quantity' => $item['quantity'],
                'price' => $item['price']
            ]);
        }

        return response()->json([
            'status' => 'success',
            'data' => $order
        ], 200);
    }

    /**
     * Create
     */
    public function create(Request $request)
    {
        // validate the request...
        $request->validate([
            'no_transaksi' => 'required',
            'tanggal' => 'required',
            'total' => 'required|numeric',
            'bayar' => 'nullable|numeric',
            'kembalian' => 'required|numeric',
            'kasir_id' => 'nullable',
            'status' => 'nullable',
        ]);

        // store the request...
        $data = new Transaksi;
        $data->id = Str::uuid()->toString();
        $data->no_transaksi = $request->no_transaksi;
        $data->tanggal = $request->tanggal;
        $data->total = $request->total;
        $data->bayar = $request->bayar;
        $data->kembalian = $request->kembalian;
        if ($request->kasir_id) $data->kasir_id = $request->kasir_id;
        $data->status = $request->status ?? 'completed';
        $data->save();

        //create order items
        foreach ($request->items as $item) {
            DetailTransaksi::create([
                'id' => Str::uuid()->toString(),
                'transaksi_id' => $data->id,
                'produk_id' => $item['produk_id'],
                'jumlah' => $item['jumlah'],
                'harga' => $item['harga'],
                'diskon' => $item['diskon'],
                'subtotal' => $item['subtotal'],
                'created_at' => $request->tanggal,
            ]);
        }

        // store to laporan keuangan
        $laporanKeuangan = new LaporanKeuangan;
        $laporanKeuangan->id = Str::uuid()->toString();
        $laporanKeuangan->tanggal = date('Y-m-d');
        $laporanKeuangan->jenis = 'pemasukan';
        $laporanKeuangan->kategori = 'Penjualan Obat';
        $laporanKeuangan->jumlah = $data->total;
        $laporanKeuangan->keterangan = $laporanKeuangan->kategori . ': ' . $data->no_transaksi;
        $laporanKeuangan->bukti_transaksi = $data->no_transaksi;
        $laporanKeuangan->created_by = $data->kasir_id;
        $laporanKeuangan->save();

        return returnJson($data, 201);
    }

    /**
     * Update
     */
    public function update(Request $request)
    {
        // // validate the request...
        // $request->validate([
        //     'kode' => 'required',
        //     'barcode' => 'nullable',
        //     'nama' => 'required',
        //     'deskripsi' => 'nullable',
        //     'kategori_id' => 'required',
        //     'harga_beli' => 'required|numeric',
        //     'harga_jual' => 'required|numeric',
        //     'stok' => 'required|numeric',
        // ]);

        // $data = Produk::findOrFail($request->id);
        // $data->kode = $request->kode;
        // if ($request->barcode) $data->barcode = $request->barcode;
        // $data->nama = $request->nama;
        // if ($request->deskripsi) $data->deskripsi = $request->deskripsi;
        // $data->kategori_id = $request->kategori_id;
        // $data->harga_beli = $request->harga_beli;
        // $data->harga_jual = $request->harga_jual;
        // $data->stok = $request->stok;

        // $data->save();
        // return returnJson($data, 200);
    }

    /**
     * Delete
     */
    public function destroy($id)
    {
        $data = Transaksi::findOrFail($id);
        $data->delete();
        return returnJson('Success');
    }

    // date => format yyyy-mm-dd
    public function calculateInDay($date)
    {
        $data = Transaksi::whereBetween('tanggal', [$date . ' 00:00:00', $date . ' 23:59:59']);
        return $data->sum('total');
    }



    // date => format strtotime
    public function calculateInMonth($strToTime)
    {
        $month = date('m', $strToTime);
        $year = date('Y', $strToTime);

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

        $data = Transaksi::whereBetween('tanggal', [$start, $end])->sum('total');
        return $data;
    }

    /**
     * Summary for Dashboard
     */
    public function dashboard()
    {
        $now = date('Y-m-d');
        $data =  new stdClass;
        $sales_today = (int) $this->calculateInDay($now);
        $data->saldo_harian = $sales_today;

        $yesterday =  date('Y-m-d', strtotime('-1 day', strtotime($now)));
        $sales_yesterday = (int) $this->calculateInDay($yesterday);
        $data->saldo_harian_kemarin = $sales_yesterday;
        $presentasi = (float) $sales_yesterday == 0 ? 0 : (($sales_today - $sales_yesterday) / $sales_yesterday);
        $data->presentasi_saldo = (float) number_format($presentasi * 100, 2, '.', '');

        $data->total_qty = (int) DetailTransaksi::whereBetween('created_at', [$now . ' 00:00:00', $now . ' 23:59:59'])->sum('jumlah');
        $data->total_transaksi = (int) Transaksi::whereBetween('tanggal', [$now . ' 00:00:00', $now . ' 23:59:59'])->get()->count();

        $harian = [];
        $bulanan = [];
        for ($i = 6; $i >= 0; $i--) {
            $day = new stdClass;
            $month = new stdClass;
            $dayTime = strtotime("-$i day", strtotime($now));

            $day->label = date('d/m', $dayTime);
            $day->value = (int) $this->calculateInDay(date('Y-m-d', $dayTime));
            $harian[] = $day;

            // for 6 month
            if ($i < 6) {
                $monthTime = strtotime("-$i month", strtotime($now));
                $month->label = date('M', $monthTime);
                $month->value = (int) $this->calculateInMonth($monthTime);
                $bulanan[] = $month;
            }
        }
        $data->harian = $harian;
        $data->bulanan = $bulanan;

        return returnJson($data);
    }
}
