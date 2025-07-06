import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:penganduan_app/Admin/Detail_laporan_AdminSuper.dart';
import 'package:penganduan_app/endPoint.dart';
import 'package:url_launcher/url_launcher.dart';

class LaporanMasuk extends StatefulWidget {
  final String? role;
  const LaporanMasuk({this.role, super.key});

  @override
  State<LaporanMasuk> createState() => _LaporanMasukState();
}

class _LaporanMasukState extends State<LaporanMasuk> {
  List<dynamic> laporanList = [];

  @override
  void initState() {
    super.initState();
    fetchLaporan();
  }

  Future<void> fetchLaporan() async {
    final response = await http.post(
      Uri.parse('${EndPoint.url}get_pengaduan.php'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'role': widget.role}),
    );

    final result = jsonDecode(response.body);

    if (result['status'] == true) {
      setState(() {
        laporanList = result['data'];
      });
    } else {
      // Error handling
      print("Gagal memuat laporan");
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Diproses':
        return Colors.orange;
      case 'Ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _generateWhatsAppMessage(Map<String, dynamic> laporan) {
    String message = '''
Halo, saya ingin melaporkan masalah berikut:

📝 *Judul Laporan:* ${laporan['judul_pengaduan']}
📅 *Tanggal:* ${laporan['tanggal']}
📂 *Kategori:* ${laporan['kategori']}
📍 *Alamat:* ${laporan['alamat']}

📋 *Deskripsi:*
${laporan['deskripsi']}

Mohon tindak lanjutnya. Terima kasih.
    ''';
    return Uri.encodeComponent(message);
  }

  Future<void> _sendToWhatsApp(
      BuildContext context, Map<String, dynamic> laporan) async {
    try {
      final String message = _generateWhatsAppMessage(laporan);
      final String whatsappUrl = 'https://wa.me/6281240546596?text=$message';
      final Uri url = Uri.parse(whatsappUrl);

      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tidak dapat membuka WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.role ?? 'ted'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: laporanList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: laporanList.length,
              itemBuilder: (context, index) {
                final laporan = laporanList[index];
                return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailLaporan(
                            laporan: laporan,
                            onStatusChanged: (updatedLaporan) {
                              fetchLaporan();
                            },
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    laporan['judul_pengaduan'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      _sendToWhatsApp(context, laporan),
                                  icon: const Icon(Icons.chat,
                                      color: Colors.green, size: 28),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Chip(
                                  label: Text(laporan['status'] ?? 'Menunggu'),
                                  backgroundColor: _getStatusColor(
                                      laporan['status'] ?? 'Menunggu'),
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(laporan['kategori']),
                                  backgroundColor: Colors.grey[200],
                                ),
                                const Spacer(),
                                Text(
                                  laporan['tanggal'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('Deskripsi:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(laporan['deskripsi']),
                            const SizedBox(height: 6),
                            const Text('Alamat:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(laporan['alamat']),
                            const SizedBox(height: 6),
                            Text(
                              'Dikirim secara anonim: ${laporan['is_anonim'] == '1' ? 'Ya' : 'Tidak'}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
              },
            ),
    );
  }
}
