import 'package:flutter/material.dart';
import 'RiwayatLaporanUser.dart';
import 'ProfilUser.dart';
import 'penggunaHome.dart';

class NotifikasiPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const NotifikasiPage({super.key, this.userData});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage>
    with TickerProviderStateMixin {
  bool _isSearchVisible = false;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Filter untuk kategori notifikasi
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Pengaduan',
    'Sistem',
    'Penting'
  ];

  int _selectedIndex = 3; // Index untuk notifikasi

  @override
  void initState() {
    super.initState();
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchVisible = !_isSearchVisible;
    });

    if (_isSearchVisible) {
      _searchAnimationController.forward();
      Future.delayed(const Duration(milliseconds: 200), () {
        _searchFocusNode.requestFocus();
      });
    } else {
      _searchAnimationController.reverse();
      _searchFocusNode.unfocus();
      _searchController.clear();
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mencari notifikasi: $query'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Data dummy notifikasi
  List<Map<String, dynamic>> _getNotifikasi() {
    final List<Map<String, dynamic>> allNotifications = [
      {
        'id': '1',
        'judul': 'Pengaduan Anda Telah Diproses',
        'pesan':
            'Pengaduan dengan nomor #PGD001 sedang dalam tahap verifikasi oleh petugas terkait.',
        'waktu': '2 menit yang lalu',
        'kategori': 'Pengaduan',
        'dibaca': false,
        'icon': Icons.assignment_turned_in,
        'color': Colors.blue,
      },
      {
        'id': '2',
        'judul': 'Tanggapan Baru dari Petugas',
        'pesan':
            'Ada tanggapan baru untuk pengaduan Anda tentang kerusakan jalan di Jl. Merdeka.',
        'waktu': '1 jam yang lalu',
        'kategori': 'Pengaduan',
        'dibaca': false,
        'icon': Icons.chat_bubble_outline,
        'color': Colors.green,
      },
      {
        'id': '3',
        'judul': 'Pemeliharaan Sistem',
        'pesan':
            'Sistem akan mengalami pemeliharaan pada tanggal 10 Juni 2025 pukul 02:00 - 04:00 WIB.',
        'waktu': '3 jam yang lalu',
        'kategori': 'Sistem',
        'dibaca': true,
        'icon': Icons.build_circle_outlined,
        'color': Colors.orange,
      },
      {
        'id': '4',
        'judul': 'Pengaduan Selesai',
        'pesan':
            'Pengaduan Anda tentang lampu jalan mati telah selesai ditangani. Terima kasih atas laporannya.',
        'waktu': '1 hari yang lalu',
        'kategori': 'Pengaduan',
        'dibaca': true,
        'icon': Icons.check_circle_outline,
        'color': Colors.green,
      },
      {
        'id': '5',
        'judul': 'Peringatan Penting',
        'pesan':
            'Harap menggunakan data yang akurat saat membuat pengaduan untuk mempercepat proses penanganan.',
        'waktu': '2 hari yang lalu',
        'kategori': 'Penting',
        'dibaca': true,
        'icon': Icons.warning_amber_outlined,
        'color': Colors.red,
      },
      {
        'id': '6',
        'judul': 'Update Aplikasi',
        'pesan':
            'Versi terbaru aplikasi telah tersedia. Silakan update untuk mendapatkan fitur terbaru.',
        'waktu': '3 hari yang lalu',
        'kategori': 'Sistem',
        'dibaca': true,
        'icon': Icons.system_update,
        'color': Colors.purple,
      },
      {
        'id': '7',
        'judul': 'Pengaduan Ditolak',
        'pesan':
            'Pengaduan #PGD002 ditolak karena data tidak lengkap. Silakan ajukan kembali dengan data yang lengkap.',
        'waktu': '1 minggu yang lalu',
        'kategori': 'Pengaduan',
        'dibaca': true,
        'icon': Icons.cancel_outlined,
        'color': Colors.red,
      },
      {
        'id': '8',
        'judul': 'Selamat Datang',
        'pesan':
            'Selamat datang di aplikasi Pengaduan Masyarakat! Terima kasih telah bergabung dengan kami.',
        'waktu': '2 minggu yang lalu',
        'kategori': 'Sistem',
        'dibaca': true,
        'icon': Icons.celebration_outlined,
        'color': Colors.blue,
      },
    ];

    // Filter berdasarkan kategori dan pencarian
    List<Map<String, dynamic>> filteredNotifications = allNotifications;

    if (_selectedFilter != 'Semua') {
      filteredNotifications = filteredNotifications
          .where((notif) => notif['kategori'] == _selectedFilter)
          .toList();
    }

    if (_searchController.text.isNotEmpty) {
      filteredNotifications = filteredNotifications
          .where((notif) =>
              notif['judul']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              notif['pesan']
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    return filteredNotifications;
  }

  void _tandaiSudahDibaca(String id) {
    setState(() {
      // Logic untuk menandai notifikasi sudah dibaca
      // Dalam implementasi nyata, ini akan update ke backend/database
    });
  }

  void _hapusNotifikasi(String id) {
    setState(() {
      // Logic untuk menghapus notifikasi
      // Dalam implementasi nyata, ini akan menghapus dari backend/database
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi berhasil dihapus'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _tandaiSemuaSudahDibaca() {
    setState(() {
      // Logic untuk menandai semua notifikasi sudah dibaca
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi ditandai sudah dibaca'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomeUser(userData: widget.userData)),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  RiwayatLaporanUser(userData: widget.userData)),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProfilUser(userData: widget.userData)),
        );
        break;
      case 3:
        // Sudah di halaman notifikasi
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifikasi = _getNotifikasi();
    final unreadCount = notifikasi.where((notif) => !notif['dibaca']).length;

    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSearchVisible
              ? SizeTransition(
                  sizeFactor: _searchAnimation,
                  axis: Axis.horizontal,
                  child: Container(
                    key: const ValueKey('search'),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onSubmitted: _onSearchSubmitted,
                      onChanged: (value) => setState(() {}),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Cari notifikasi...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                )
              : Row(
                  key: const ValueKey('title'),
                  children: [
                    const Text('Notifikasi'),
                    if (unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isSearchVisible && unreadCount > 0)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _tandaiSemuaSudahDibaca,
              tooltip: 'Tandai semua sudah dibaca',
            ),
          AnimatedRotation(
            turns: _isSearchVisible ? 0.25 : 0,
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
              tooltip: _isSearchVisible ? 'Tutup pencarian' : 'Cari notifikasi',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Results Section
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height:
                _isSearchVisible && _searchController.text.isNotEmpty ? 60 : 0,
            child: _isSearchVisible && _searchController.text.isNotEmpty
                ? Container(
                    width: double.infinity,
                    color: Colors.grey.shade100,
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Hasil pencarian untuk: "${_searchController.text}"',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),

          // Header dengan statistik dan filter
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Notifikasi Anda',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${notifikasi.length} notifikasi total',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white70),
                        ),
                      ],
                    ),
                    if (unreadCount > 0)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$unreadCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Belum Dibaca',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: Colors.white.withOpacity(0.2),
                          selectedColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.blue : Colors.white,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          checkmarkColor: Colors.blue,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Daftar notifikasi
          Expanded(
            child: notifikasi.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Tidak ada notifikasi yang cocok'
                              : 'Belum ada notifikasi',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isNotEmpty
                              ? 'Coba kata kunci yang berbeda'
                              : 'Notifikasi akan muncul di sini',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifikasi.length,
                    itemBuilder: (context, index) {
                      final notif = notifikasi[index];
                      return Dismissible(
                        key: Key(notif['id']),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        onDismissed: (direction) {
                          _hapusNotifikasi(notif['id']);
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: notif['dibaca'] ? 1 : 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: notif['dibaca']
                                  ? Colors.grey.shade200
                                  : Colors.blue.shade200,
                              width: notif['dibaca'] ? 1 : 2,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              if (!notif['dibaca']) {
                                _tandaiSudahDibaca(notif['id']);
                              }
                              // Navigasi ke detail notifikasi jika diperlukan
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: notif['color'].withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      notif['icon'],
                                      color: notif['color'],
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                notif['judul'],
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: notif['dibaca']
                                                      ? FontWeight.w600
                                                      : FontWeight.bold,
                                                  color: notif['dibaca']
                                                      ? Colors.grey.shade700
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            if (!notif['dibaca'])
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notif['pesan'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            height: 1.4,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              notif['waktu'],
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: notif['color']
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                notif['kategori'],
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: notif['color'],
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
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
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications, color: Colors.blue),
            label: 'Notifikasi',
          ),
        ],
      ),
    );
  }
}
