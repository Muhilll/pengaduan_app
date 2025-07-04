import 'package:flutter/material.dart';
import 'package:penganduan_app/Admin/Laporan_Keamanan.dart';
import 'package:penganduan_app/Admin/daftar_pengguna.dart';

class AdminKeamananMenu extends StatefulWidget {
  const AdminKeamananMenu({super.key});

  @override
  State<AdminKeamananMenu> createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminKeamananMenu> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardPage(),
    const LaporanKeamanan(),
    const DaftarPengguna(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Pengaduan'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pengguna'),
        ],
      ),
    );
  }
}

class _DashboardPage extends StatelessWidget {
  const _DashboardPage();

  final List<String> adminHistory = const [
    'Menanggapi pengaduan #123',
    'Memverifikasi akun pengguna: johndoe',
    'Menghapus pengaduan #122',
    'Menambahkan admin baru: admin2',
    'Mengubah status pengaduan #121 menjadi "Selesai"',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Selamat Datang, Admin!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Berikut adalah aktivitas terbaru yang Anda lakukan:',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Riwayat Admin
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Riwayat Aktivitas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: adminHistory.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        title: Text(adminHistory[index]),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
