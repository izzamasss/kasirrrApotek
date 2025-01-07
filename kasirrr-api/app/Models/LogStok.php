<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class LogStok extends Model
{
    use HasUuids;
    protected $table = 'log_stok';
    public $timestamps = false;
    protected $fillable = [
        'produk_id',
        'jenis_perubahan',
        'jumlah',
        'stok_sebelum',
        'stok_sesudah',
        'keterangan',
        'petugas_id',
        'created_at',
    ];

    public function produk()
    {
        return $this->belongsTo(Produk::class, 'produk_id');
    }
}
