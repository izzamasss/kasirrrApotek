<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Kategori extends Model
{
    use HasUuids;
    protected $table = 'kategori';

    protected $fillable = [
        'nama',
        'deskripsi',
        'is_aktif',
    ];

    protected $hidden = [
        'created_at',
        'updated_at',
    ];

    public function produk()
    {
        return $this->hasMany(Produk::class);
    }
}
