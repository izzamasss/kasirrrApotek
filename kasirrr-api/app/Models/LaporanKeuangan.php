<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class LaporanKeuangan extends Model
{
    use HasUuids;
    protected $table = 'laporan_keuangan';
    protected $fillable = [
        'tanggal',
        'jenis',
        'kategori',
        'jumlah',
        'keterangan',
        'bukti_transaksi',
        'created_by',
    ];

    protected $hidden = [
        'updated_at',
    ];


    public function pengguna()
    {
        return $this->belongsTo(Pengguna::class, 'created_by');
    }
}
