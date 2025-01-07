<?php

if (! function_exists('authUser')) {
    // custom get data auth
    function authUser()
    {
        $user = auth('sanctum')->user();
        $data = new \stdClass;
        $data->id = $user->id;
        $data->name = $user->name;
        $data->role = $user->role;
        $data->is_admin = str_contains($user->role, 'admin');
        return $data;
    }
}

if (! function_exists('authOutlet')) {
    function authOutlet()
    {
        return session('outlet', null);
    }
}

if (! function_exists('isAdmin')) {
    function isAdmin()
    {
        return authUser()->is_admin;
    }
}

if (! function_exists('isSuperAdmin')) {
    function isSuperAdmin()
    {
        return authUser()->role == 'superadmin';
    }
}

// --------------- start for api
if (! function_exists('returnJson')) {
    function returnJson($data, $code = 200)
    {
        return response()->json([
            'is_success' => true,
            'message' => 'Proses Berhasil',
            'data' => $data
        ], $code);
    }
}

if (! function_exists('returnJsonFailed')) {
    function returnJsonFailed($msg = 'Proses Gagal', $data = null)
    {
        return response()->json([
            'is_success' => false,
            'message' => $msg,
            'data' => $data
        ], 400);
    }
}

if (! function_exists('returnJsonNotAllowed')) {
    function returnJsonNotAllowed()
    {
        return response()->json([
            'is_success' => false,
            'message' => 'Method Not Allowed',
            'data' => null
        ], 405);
    }
}


// --------------- end for api
