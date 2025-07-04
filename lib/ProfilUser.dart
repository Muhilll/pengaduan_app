import 'package:flutter/material.dart';
import 'package:penganduan_app/RiwayatLaporanUser.dart';
import 'package:penganduan_app/notifikasi.dart';
import 'penggunaHome.dart';

int a=0;

class ProfilUser extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilUser({super.key, this.userData});

  @override
  State<ProfilUser> createState() => _ProfilUserState();
}

class _ProfilUserState extends State<ProfilUser> {
  int _selectedIndex = 2; // Index untuk Profil

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomeUser(userData: widget.userData)),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  RiwayatLaporanUser(userData: widget.userData)),
          (route) => false,
        );
        break;
      case 2:
        // Sudah di halaman profil
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data user dari parameter atau data dummy jika tidak ada
    final Map<String, String> userData;
    if (widget.userData != null) {
      // Helper untuk mengambil data dan memberikan fallback jika null atau kosong
      String getValue(String key, String fallback) {
        final value = widget.userData![key]?.toString() ?? '';
        return value.isNotEmpty ? value : fallback;
      }

      userData = {
        'nama': getValue('nama', 'User'),
        'email': getValue('email', 'user@example.com'),
        'alamat': getValue('alamat', 'Alamat tidak tersedia'),
        'no_hp': getValue('no_hp', 'No. HP tidak tersedia'),
      };
    } else {
      // Fallback jika tidak ada data sama sekali
      userData = {
        'nama': 'Edwin jago',
        'email': 'edwin@gmail.com',
        'alamat': 'Jl. Kebangsaan No. 12, Amerika Utara',
        'no_hp': '081234567890',
      };
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => HomeUser(userData: widget.userData)),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profil Saya'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Foto profil
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: const AssetImage(
                    'assets/images/profile.png',
                  ), // Ganti sesuai aset kamu
                ),
                const SizedBox(height: 20),
                Text(
                  userData['nama']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  userData['email']!,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Divider(height: 40),

                // Info tambahan
                _buildInfoTile('Alamat', userData['alamat']!),
                const SizedBox(height: 10),
                _buildInfoTile('No. HP', userData['no_hp']!),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 8,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home, color: Colors.blue),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history, color: Colors.blue),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person, color: Colors.blue),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk menampilkan info
  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(value),
      leading: const Icon(Icons.info_outline, color: Colors.blue),
    );
  }
}