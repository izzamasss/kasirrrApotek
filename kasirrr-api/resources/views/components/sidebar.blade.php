<?php
$outlet = authOutlet();
$isShowMenu = $outlet != null;
?>
<div class="main-sidebar sidebar-style-2">
    <aside id="sidebar-wrapper">
        <div class="sidebar-brand">
            <a href="#"> <img src="{{ asset('img/skuy-text.png') }}" height="50%" /></a>

        </div>
        <div class="sidebar-brand sidebar-brand-sm">
            <a href="#">SP</a>
        </div>
        <ul class="sidebar-menu">
            <li class='nav-item'>
                <a class="nav-link" href="{{ route('home') }}"><i class="fas fa-home"></i>Home</a>
            </li>

            <?php if (isAdmin()): ?>
            <li class='nav-item'>
                <a class="nav-link" href="{{ route('outlets.index') }}"><i class="fas fa-store"></i>Outlets</a>
            </li>
            <?php endif; ?>

            <?php if($isShowMenu): ?>
            <?php if (isAdmin()): ?>
            <li class='nav-item'>
                <a class="nav-link" href="{{ route('users.index') }}"><i class="fas fa-house-user"></i>Users</a>
            </li>
            <?php endif; ?>

            <li class='nav-item'>
                <a class="nav-link" href="{{ route('products.index') }}"><i class="fas fa-kitchen-set"></i>Products</a>
            </li>


            <li class='nav-item'>
                <a class="nav-link" href="{{ route('categories.index') }}"><i class="fas fa-shapes"></i>Categories</a>
            </li>
            <?php endif; ?>


            </li>




</div>
