import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LaporanPelayanan extends StatelessWidget {
  const LaporanPelayanan({super.key});

  final List<Map<String, dynamic>> laporanList = const [
    {
      'judul': 'Jalan rusak di Jalan Merdeka',
      'status': 'Diproses',
      'tanggal': '12 Mei 2025',
      'kategori': 'Pelayanan Publik',
      'deskripsi':
          'Jalan mengalami kerusakan parah di beberapa titik, membahayakan pengendara.',
      'alamat': 'Jalan Merdeka No. 45, Jakarta Pusat',
      'foto': null,
      'anonim': false,
      'instansi': 'Dinas Pekerjaan Umum Jakarta',
      'nomorWa': '628123456789', // Nomor WhatsApp instansi
    },
    {
      'judul': 'Lampu jalan mati di Blok A',
      'status': 'Selesai',
      'tanggal': '10 Mei 2025',
      'kategori': 'Pelayanan Publik',
      'deskripsi': 'Lampu jalan di Blok A sudah tidak berfungsi selama 3 hari.',
      'alamat': 'Perumahan Blok A, Jakarta Selatan',
      'foto': null,
      'anonim': true,
      'instansi': 'PLN Jakarta Selatan',
      'nomorWa': '628987654321',
    },
    {
      'judul': 'Sampah menumpuk di taman kota',
      'status': 'Ditolak',
      'tanggal': '8 Mei 2025',
      'kategori': 'Pelayanan Publik',
      'deskripsi':
          'Sampah menumpuk di taman kota dan tidak diangkut selama seminggu.',
      'alamat': 'Taman Kota Jakarta, Jakarta Pusat',
      'foto': null,
      'anonim': false,
      'instansi': 'Dinas Kebersihan Jakarta',
      'nomorWa': '628555666777',
    },
  ];

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

📝 *Judul Laporan:* ${laporan['judul']}
📅 *Tanggal:* ${laporan['tanggal']}
📂 *Kategori:* ${laporan['kategori']}
📍 *Alamat:* ${laporan['alamat']}

📋 *Deskripsi:*
${laporan['deskripsi']}

🏢 *Instansi Terkait:* ${laporan['instansi']}

Mohon tindak lanjutnya. Terima kasih.
    ''';
    return Uri.encodeComponent(message);
  }

  Future<void> _sendToWhatsApp(
      BuildContext context, Map<String, dynamic> laporan) async {
    try {
      final String message = _generateWhatsAppMessage(laporan);
      final String whatsappUrl =
          'https://wa.me/${laporan['087752383414']}?text=$message';
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
        title: const Text('Laporan Masuk'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: laporanList.length,
        itemBuilder: (context, index) {
          final laporan = laporanList[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                          laporan['judul'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _sendToWhatsApp(context, laporan),
                        icon: const Icon(
                          Icons.chat,
                          color: Colors.green,
                          size: 28,
                        ),
                        tooltip: 'Kirim ke WhatsApp ${laporan['instansi']}',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Chip(
                        label: Text(laporan['status']),
                        backgroundColor: _getStatusColor(laporan['status']),
                        labelStyle: const TextStyle(color: Colors.white),
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
                  const Text(
                    'Instansi Terkait:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    laporan['instansi'],
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Deskripsi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(laporan['deskripsi']),
                  const SizedBox(height: 6),
                  const Text(
                    'Alamat:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(laporan['alamat']),
                  const SizedBox(height: 6),
                  Text(
                    'Dikirim secara anonim: ${laporan['anonim'] ? "Ya" : "Tidak"}',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
