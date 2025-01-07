import 'package:apotek/constants/extensions.dart';
import 'package:apotek/constants/variable.dart';
import 'package:apotek/utils/shared_pref_util.dart';
import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'kasir/kasir_page.dart';
import 'produk/produk_page.dart';
import 'kategori_page.dart';
import 'manajemen_stok/manajemen_stok_page.dart';
import 'laporan_page.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'pengguna/pengguna_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;
  bool _isAnimationDrawerFinished = false;
  bool get isAdmin => Variable.pengguna?.isAdmin ?? false;

  List<Menu> get _menus => [
        const Menu(label: 'Dashboard', icon: Icons.dashboard, page: DashboardPage()),
        if (!isAdmin) const Menu(label: 'Kasir', icon: Icons.point_of_sale, page: KasirPage()),
        if (isAdmin) ...[
          const Menu(label: 'Produk', icon: Icons.inventory, page: ProdukPage()),
          const Menu(label: 'Kategori', icon: Icons.category, page: KategoriPage()),
          const Menu(label: 'Manajemen Stok', icon: Icons.inventory_2, page: ManajemenStokPage()),
          const Menu(label: 'Laporan', icon: Icons.assessment, page: LaporanPage()),
          const Menu(label: 'Pengguna', icon: Icons.people, page: PenggunaPage()),
        ],
      ];

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              SharedPrefUtil().removeAuthData();
              // Hapus token dan kembali ke halaman login
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            setState(() {
              _isDrawerOpen = !_isDrawerOpen;
              _isAnimationDrawerFinished = false;
            });
          },
        ),
        title: const Text(
          'APOTEK ALIDA FARMA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) {
              if (value == 'logout') {
                _showLogoutDialog();
              } else if (value == 'profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Row(
        children: [
          AnimatedContainer(
            onEnd: () => setState(() {
              _isAnimationDrawerFinished = true;
            }),
            duration: const Duration(milliseconds: 300),
            width: _isDrawerOpen ? 150 : 0,
            child: Container(
              color: Colors.green,
              child: ListView(
                padding: 10.edgeVer,
                children: List.generate(_menus.length, (i) {
                  final menu = _menus[i];
                  return GestureDetector(
                    onTap: () => _onItemTapped(i),
                    child: Container(
                      padding: 16.edgeAll,
                      child: _isDrawerOpen && _isAnimationDrawerFinished
                          ? Row(
                              children: [
                                Icon(menu.icon, color: Colors.white),
                                4.gapW,
                                Expanded(child: Text(menu.label, style: const TextStyle(color: Colors.white))),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  );
                }),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: _menus[_selectedIndex].page,
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isDrawerOpen = false; // Menutup drawer setelah item dipilih
    });
  }
}

class Menu {
  const Menu({required this.label, required this.icon, required this.page});
  final String label;
  final IconData icon;
  final Widget page;
}
