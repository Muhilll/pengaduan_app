import 'package:flutter/material.dart';
import 'package:penganduan_app/endPoint.dart'; // agar bisa akses EndPoint.url
import 'package:url_launcher/url_launcher.dart'; // untuk buka file

class DetailRiwayat extends StatelessWidget {
  final Map<String, dynamic> data;

  const DetailRiwayat({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isAnonim = data['is_anonim'] == 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['judul_pengaduan'] ?? '-',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.category, size: 20),
                const SizedBox(width: 8),
                Text("Kategori: ${data['kategori'] ?? '-'}"),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              "Deskripsi:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(data['deskripsi'] ?? '-'),
            const SizedBox(height: 12),

            const Text(
              "Lokasi Kejadian:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(data['alamat'] ?? '-')),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.date_range, size: 20),
                const SizedBox(width: 8),
                Text("Tanggal: ${data['tanggal'] ?? '-'}"),
              ],
            ),
            const SizedBox(height: 12),

            const Text(
              "Lampiran Berkas:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (data['lampiran'] != null)
              ElevatedButton.icon(
                onPressed: () async {
                  final url = Uri.parse('${EndPoint.url}uploads/lampiran/${data['lampiran']}');
                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tidak dapat membuka lampiran'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.attach_file),
                label: const Text("Lihat Berkas"),
              )
            else
              const Text("Tidak ada lampiran."),
            const SizedBox(height: 12),

            const Text("Foto:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (data['foto'] != null && data['foto'].toString().isNotEmpty)
              Image.network(
                '${EndPoint.url}uploads/foto/${data['foto']}',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Text("Gagal memuat foto."),
              )
            else
              const Text("Tidak ada foto."),
            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.privacy_tip),
                const SizedBox(width: 8),
                Text(isAnonim
                    ? "Pesan ini bersifat Anonim"
                    : "Pesan ini menampilkan identitas"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}