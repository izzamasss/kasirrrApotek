<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Pengguna extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasUuids;
    protected $table = 'pengguna';
    protected $fillable = [
        'username',
        'password',
        'nama',
        'role',
        'email',
        'telepon',
        'foto_profile',
        'is_aktif',
        'last_login',
        'created_at',
        'updated_at',
    ];

    protected $hidden = [
        'last_login',
        'password',
        'updated_at',
    ];

    protected $casts = [
        'password' => 'hashed',
    ];
}
