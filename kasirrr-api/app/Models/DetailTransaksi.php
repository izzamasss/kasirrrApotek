<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class DetailTransaksi extends Model
{
    use HasUuids;
    protected $table = 'detail_transaksi';
    public $timestamps = false;
    protected $fillable = [
        'transaksi_id',
        'produk_id',
        'jumlah',
        'harga',
        'diskon',
        'subtotal',
    ];

    public function produk()
    {
        return $this->belongsTo(Produk::class);
    }

    public function transaksi()
    {
        return $this->belongsTo(Transaksi::class);
    }
}
