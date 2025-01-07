<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use App\Models\Kategori;

class Produk extends Model
{
    use HasUuids;
    protected $table = 'produk';

    protected $fillable = [
        'kode',
        'barcode',
        'nama',
        'deskripsi',
        'kategori_id',
        'harga_beli',
        'harga_jual',
        'stok',
        'min_stok',
        'is_aktif',
    ];

    protected $hidden = [
        'created_at',
        'updated_at',
    ];

    public function kategori()
    {
        return $this->belongsTo(Kategori::class, 'kategori_id');
    }
}
