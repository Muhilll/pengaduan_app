import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:penganduan_app/DetailRiwayat.dart';
import 'package:penganduan_app/endPoint.dart';
import 'package:penganduan_app/notifikasi.dart';
import 'package:penganduan_app/ProfilUser.dart';
import 'penggunaHome.dart';

class RiwayatLaporanUser extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RiwayatLaporanUser({super.key, this.userData});

  @override
  State<RiwayatLaporanUser> createState() => _RiwayatLaporanUserState();
}

class _RiwayatLaporanUserState extends State<RiwayatLaporanUser> {
  int _selectedIndex = 1;
  List<dynamic> laporanList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRiwayatLaporan();
  }

  Future<void> fetchRiwayatLaporan() async {
    final userId = widget.userData?['id'];
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('${EndPoint.url}get_pengaduan_user.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id_user': userId}),
      );

      final data = jsonDecode(response.body);
      if (data['status']) {
        setState(() {
          laporanList = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat laporan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Icon _getStatusIcon(String status) {
    switch (status) {
      case 'Selesai':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'Diproses':
        return const Icon(Icons.sync, color: Colors.orange);
      case 'Ditolak':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);

    final userData = widget.userData;
    final pages = [
      HomeUser(userData: userData),
      null,
      ProfilUser(userData: userData),
    ];

    if (pages[index] != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => pages[index]!),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          title: const Text('Riwayat Laporan Saya'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: laporanList.isEmpty
                    ? const Center(child: Text('Belum ada laporan.'))
                    : ListView.builder(
                        itemCount: laporanList.length,
                        itemBuilder: (context, index) {
                          final laporan = laporanList[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: _getStatusIcon(laporan['status']),
                              title: Text(
                                laporan['judul_pengaduan'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Status: ${laporan['status']}\nTanggal: ${laporan['tanggal']}',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailRiwayat(data: laporan),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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
}
