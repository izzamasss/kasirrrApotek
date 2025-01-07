@extends('layouts.app')

@section('title', 'Dashboard')

@push('style')
    <!-- CSS Libraries -->
    <link rel="stylesheet" href="{{ asset('library/jqvmap/dist/jqvmap.min.css') }}">
    <link rel="stylesheet" href="{{ asset('library/summernote/dist/summernote-bs4.min.css') }}">
@endpush

@section('main')
    <?php
    // echo json_encode(authUser());
    
    // exit();
    ?>
    <div class="main-content" style="min-width: 90%">
        <section class="section">
            <div class="section-header">
                <h1>Dashboard</h1>
            </div>
            <div class="row">

                <div class="col-12 col md-12 col-lg-12">
                    <div class="row">
                        <div class="col-12">
                            @include('layouts.alert')
                        </div>
                    </div>
                    <div class="card">
                        <div class="card-header">
                            <h4>Choose your outlet</h4>
                        </div>
                        <div class="card-body">

                            <form action="{{ route('home') }}" method="POST">
                                @csrf
                                <div class="card-body">
                                    <div class="form-group row">
                                        <div class="col">
                                            <select class="form-control selectric @error('outlet_id') is-invalid @enderror"
                                                name="outlet_id">
                                                <option value="">Choose Outlet</option>
                                                @foreach ($outletsUsers as $outlet)
                                                    < <option value="{{ $outlet->outlets->id }}"
                                                        {{ $outlet->outlets->id == $outletId ? 'selected' : '' }}>
                                                        {{ $outlet->outlets->name }}
                                                        </option>
                                                @endforeach
                                            </select>
                                        </div>
                                        <button class="btn btn-primary col-sm-2">Submit</button>
                                    </div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>

        </section>
    </div>
@endsection

@push('scripts')
    <!-- JS Libraies -->
    <script src="{{ asset('library/simpleweather/jquery.simpleWeather.min.js') }}"></script>
    <script src="{{ asset('library/chart.js/dist/Chart.min.js') }}"></script>
    <script src="{{ asset('library/jqvmap/dist/jquery.vmap.min.js') }}"></script>
    <script src="{{ asset('library/jqvmap/dist/maps/jquery.vmap.world.js') }}"></script>
    <script src="{{ asset('library/summernote/dist/summernote-bs4.min.js') }}"></script>
    <script src="{{ asset('library/chocolat/dist/js/jquery.chocolat.min.js') }}"></script>

    <!-- Page Specific JS File -->
    {{-- <script src="{{ asset('js/page/index-0.js') }}"></script> --}}
@endpush
