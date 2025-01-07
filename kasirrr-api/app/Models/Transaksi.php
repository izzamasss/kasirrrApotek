<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Transaksi extends Model
{
    use HasUuids;
    protected $table = 'transaksi';
    protected $fillable = [
        'no_transaksi',
        'tanggal',
        'total',
        'bayar',
        'kembalian',
        'kasir_id',
        'status',
    ];

    protected $hidden = [
        'created_at',
        'updated_at',
    ];

    public function products()
    {
        return $this->hasMany(Produk::class);
    }
}
