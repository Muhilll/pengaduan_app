import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Tambahkan package chart
import 'FormPengaduan.dart';
import 'FormLogin.dart';
import 'splash_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pengaduan Masyarakat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

// Enum untuk periode waktu
enum TimePeriod { weekly, monthly, yearly }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  bool _isSearchVisible = false;
  late AnimationController _searchAnimationController;
  late Animation<double> _searchAnimation;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Variabel untuk periode waktu
  TimePeriod _selectedPeriod = TimePeriod.weekly;

  int _selectedIndex = 0;

  bool _isLoading = false;
  String? _errorMessage;
  double _maxY = 0;
  double _yInterval = 0;
  List<FlSpot> _chartData = [];
  List<String> _chartLabels = [];
  int _totalPengaduan = 0;
  int _belumDiproses = 0;
  int _sedangDiproses = 0;
  int _selesai = 0;

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
        break;
      case 1:
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
    }
  }

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
      // Delay untuk fokus agar animasi berjalan dulu
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
      // Implementasi logic pencarian di sini
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mencari: $query'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Fungsi untuk mendapatkan data berdasarkan periode
  List<FlSpot> _getDataForPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return [
          FlSpot(0, 3),
          FlSpot(1, 5),
          FlSpot(2, 4),
          FlSpot(3, 6),
          FlSpot(4, 9),
          FlSpot(5, 8),
          FlSpot(6, 12),
        ];
      case TimePeriod.monthly:
        return [
          FlSpot(0, 25),
          FlSpot(1, 32),
          FlSpot(2, 28),
          FlSpot(3, 41),
          FlSpot(4, 38),
          FlSpot(5, 45),
          FlSpot(6, 52),
          FlSpot(7, 48),
          FlSpot(8, 56),
          FlSpot(9, 63),
          FlSpot(10, 58),
          FlSpot(11, 71),
        ];
      case TimePeriod.yearly:
        return [
          FlSpot(0, 245),
          FlSpot(1, 312),
          FlSpot(2, 398),
          FlSpot(3, 456),
          FlSpot(4, 523),
        ];
    }
  }

  // Fungsi untuk mendapatkan label X-axis berdasarkan periode
  List<String> _getLabelsForPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      case TimePeriod.monthly:
        return [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'Mei',
          'Jun',
          'Jul',
          'Agu',
          'Sep',
          'Okt',
          'Nov',
          'Des'
        ];
      case TimePeriod.yearly:
        return ['2020', '2021', '2022', 'ة2023', '2024'];
    }
  }

  // Fungsi untuk mendapatkan nilai maksimum Y berdasarkan periode
  double _getMaxYForPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return 15;
      case TimePeriod.monthly:
        return 80;
      case TimePeriod.yearly:
        return 600;
    }
  }

  // Fungsi untuk mendapatkan interval Y berdasarkan periode
  double _getYIntervalForPeriod(TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return 2;
      case TimePeriod.monthly:
        return 10;
      case TimePeriod.yearly:
        return 100;
    }
  }

  // Fungsi untuk mendapatkan nama periode
  String _getPeriodName(TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return 'Mingguan';
      case TimePeriod.monthly:
        return 'Bulanan';
      case TimePeriod.yearly:
        return 'Tahunan';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data untuk grafik berdasarkan periode yang dipilih
    final List<FlSpot> dataPoints = _getDataForPeriod(_selectedPeriod);
    final List<String> labels = _getLabelsForPeriod(_selectedPeriod);
    final double maxY = _getMaxYForPeriod(_selectedPeriod);
    final double yInterval = _getYIntervalForPeriod(_selectedPeriod);

    // Total pengaduan (bisa disesuaikan berdasarkan periode)
    final int totalPengaduan = _selectedPeriod == TimePeriod.weekly
        ? 47
        : _selectedPeriod == TimePeriod.monthly
            ? 567
            : 2934;

    // Data status pengaduan (bisa disesuaikan berdasarkan periode)
    final int belumDiproses = _selectedPeriod == TimePeriod.weekly
        ? 12
        : _selectedPeriod == TimePeriod.monthly
            ? 98
            : 456;
    final int sedangDiproses = _selectedPeriod == TimePeriod.weekly
        ? 18
        : _selectedPeriod == TimePeriod.monthly
            ? 156
            : 892;
    final int selesai = _selectedPeriod == TimePeriod.weekly
        ? 17
        : _selectedPeriod == TimePeriod.monthly
            ? 313
            : 1586;

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
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Cari pengaduan...',
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                )
              : const Text(
                  'Pengaduan Masyarakat',
                  key: ValueKey('title'),
                ),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          AnimatedRotation(
            turns: _isSearchVisible ? 0.25 : 0,
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
              onPressed: _toggleSearch,
              tooltip: _isSearchVisible ? 'Tutup pencarian' : 'Cari',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Results Section (muncul ketika ada pencarian)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isSearchVisible && _searchController.text.isNotEmpty
                  ? 60
                  : 0,
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
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sampaikan pengaduan Anda dengan mudah dan cepat',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BuatPengaduanPage(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Pengaduan Baru'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Statistik Pengaduan',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      // Dropdown untuk memilih periode
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.blue.shade50,
                        ),
                        child: DropdownButton<TimePeriod>(
                          value: _selectedPeriod,
                          underline: const SizedBox(),
                          icon: Icon(Icons.arrow_drop_down,
                              color: Colors.blue.shade600),
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          items: TimePeriod.values.map((TimePeriod period) {
                            return DropdownMenuItem<TimePeriod>(
                              value: period,
                              child: Text(_getPeriodName(period)),
                            );
                          }).toList(),
                          onChanged: (TimePeriod? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedPeriod = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Grafik jumlah pengaduan
                  Container(
                    height: 300,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: yInterval,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                          getDrawingVerticalLine: (value) {
                            return FlLine(
                              color: Colors.grey.withOpacity(0.2),
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 &&
                                    value.toInt() < labels.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      labels[value.toInt()],
                                      style: const TextStyle(
                                        color: Color(0xff68737d),
                                        fontSize: 12,
                                      ),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(
                                    color: Color(0xff68737d),
                                    fontSize: 12,
                                  ),
                                );
                              },
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        minX: 0,
                        maxX: (labels.length - 1).toDouble(),
                        minY: 0,
                        maxY: maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: dataPoints,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.blue,
                                  strokeWidth: 1,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info total pengaduan
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Total Pengaduan ${_getPeriodName(_selectedPeriod)}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$totalPengaduan',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Text(
                          'Pengaduan',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status pengaduan
                  Text(
                    'Status Pengaduan ${_getPeriodName(_selectedPeriod)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      // Belum Diproses
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.pending_actions,
                                size: 32,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$belumDiproses',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Belum\nDiproses',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Sedang Diproses
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.sync,
                                size: 32,
                                color: Colors.blue.shade600,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$sedangDiproses',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Sedang\nDiproses',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Selesai
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 32,
                                color: Colors.green.shade600,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$selesai',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Telah\nSelesai',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ],
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
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: Colors.blue),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}
