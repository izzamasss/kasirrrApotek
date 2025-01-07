<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Pengguna;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;

class AuthController extends Controller
{
    /**
     * Login.
     */
    public function login(Request $request)
    {
        //validate the request...
        $request->validate([
            'username' => 'required',
            'password' => 'required',
        ]);

        //check if the user exists
        $data = Pengguna::where('username', $request->username)->first();
        if (!$data) return returnJsonFailed('User not found', 404);

        //check if the password is correct
        if (!Hash::check($request->password, $data->password)) {
            return returnJsonFailed('Invalid credentials', 401);
        }

        //generate token
        // $token = $user->createToken('auth-token')->plainTextToken;

        return returnJson($data);
    }

    /**
     * Get
     */
    public function show(Request $request)
    {
        $search = $request->input('search');
        $data = new Pengguna;
        if ($search) {
            $data = $data->where('nama', 'like', '%' . $search . '%')
                ->orWhere('email', 'like', '%' . $search . '%');
        }
        $data = $data->orderBy('nama')->get();
        return returnJson($data);
    }

    /**
     * Create
     */
    public function create(Request $request)
    {
        // validate the request...
        $request->validate([
            'username' => 'required|unique:pengguna',
            'nama' => 'required',
            'role' => 'required',
            'password' => 'required',
            'email' => 'required|email',
            'telepon' => 'nullable',
            'foto_profile' => 'nullable',
        ]);

        // store the request...
        $data = new Pengguna;
        $data->id = Str::uuid()->toString();
        $data->username = $request->username;
        $data->nama = $request->nama;
        $data->role = $request->role;
        $data->password = Hash::make($request->password);
        $data->is_aktif = true;
        $data->email = $request->email;
        $data->telepon = $request->telepon;
        $data->save();

        return returnJson($data, 201);
    }


    /**
     * Change Image
     */
    public function changeFotoProfil(Request $request)
    {
        // validate the request...
        $request->validate([
            'foto_profile' => 'required|image',
        ]);
        if ($request->hasFile('foto_profile')) {
            $data = Pengguna::findOrFail($request->id);
            $path = $request->file('foto_profile')->store('images');
            $data->foto_profile = $path;
            $data->save();
            return returnJson($data, 200);
        }
        // $data = [];
        // $data['foto'] = $request->hasFile('foto_profile');

        // return returnJson($data, 200);
        // 
        return returnJsonFailed('foto_profile required');
    }

    /**
     * Update
     */
    public function update(Request $request)
    {
        $request->validate([
            'username' => 'required',
            'nama' => 'required',
            'role' => 'required',
            'email' => 'required',
            'telepon' => 'nullable',
            'foto_profile' => 'nullable|image',
        ]);
        $data = Pengguna::findOrFail($request->id);
        $data->username = $request->username;
        $data->nama = $request->nama;
        $data->role = $request->role;
        if ($request->email) $data->email = $request->email;
        if ($request->telepon) $data->telepon = $request->telepon;
        // if ($request->foto_profile) $data->foto_profile = $request->foto_profile;
        if ($request->hasFile('foto_profile')) {
            // $path = $request->file('foto_profile')->store('images');
            // $data->foto_profile = $path;

            // $image = $request->file('foto_profile');
            // $image->storeAs('public/', $request->id . '.' . $image->getClientOriginalExtension());
            // $data->foto_profile = 'storage/' . $request->id . '.' . $image->getClientOriginalExtension();
            $image = $request->file('foto_profile');
            $dir = "test/";
            $imageName = \Carbon\Carbon::now()->toDateString() . "-" . uniqid() . "." . "png";
            if (!Storage::disk('public')->exists($dir)) {
                Storage::disk('public')->makeDirectory($dir);
            }
            Storage::disk('public')->put($dir . $imageName, file_get_contents($image));
        }

        $data->save();
        return returnJson($data);
    }

    /**
     * Delete
     */
    public function destroy($id)
    {
        $data = Pengguna::findOrFail($id);
        $data->delete();
        return returnJson('Success');
    }



    /**
     * Change Status isAktif
     */
    public function changeStatus(Request $request)
    {
        $request->validate([
            'is_aktif' => 'required',
        ]);
        $data = Pengguna::findOrFail($request->id);
        $data->is_aktif = $request->is_aktif;
        $data->save();
        return returnJson($data);
    }


    /**
     * Reset Password
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'password' => 'required'
        ]);
        $data = Pengguna::findOrFail($request->id);
        $data->password = Hash::make($request->password);
        $data->save();
        return returnJson($data);
    }
}
