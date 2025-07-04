import 'package:flutter/material.dart';
import 'package:penganduan_app/endPoint.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailLaporan extends StatefulWidget {
  final Map<String, dynamic> laporan;
  final Function(Map<String, dynamic>) onStatusChanged;

  const DetailLaporan({
    super.key,
    required this.laporan,
    required this.onStatusChanged,
  });

  @override
  State<DetailLaporan> createState() => _DetailLaporanState();
}

class _DetailLaporanState extends State<DetailLaporan> {
  late String selectedStatus;
  final List<String> statusOptions = ['Diproses', 'Selesai', 'Ditolak'];

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.laporan['status'] ?? 'Menunggu';
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Selesai':
        return Icons.check_circle;
      case 'Diproses':
        return Icons.schedule;
      case 'Ditolak':
        return Icons.cancel;
      default:
        return Icons.help;
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

🏢 *Instansi Terkait:* ${laporan['kategori']}

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

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ubah Status Laporan'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: statusOptions.map((status) {
                  return RadioListTile<String>(
                    title: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(status),
                      ],
                    ),
                    value: status,
                    groupValue: selectedStatus,
                    onChanged: (String? value) {
                      setDialogState(() {
                        selectedStatus = value!;
                      });
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                _updateStatus();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> simpanStatus() async {
    final url = Uri.parse('${EndPoint.url}ubah_status.php');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_pengaduan': widget.laporan['id_pengaduan'],
        'status': selectedStatus,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status']) {
      // Sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message']), backgroundColor: Colors.green),
      );
      widget.laporan['status'] = selectedStatus;
      widget.onStatusChanged(widget.laporan);
      setState(() {});
      Navigator.pop(context);
    } else {
      // Gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
      );
    }
  }

  void _updateStatus() {
    setState(() {
      widget.laporan['status'] = selectedStatus;
    });
    widget.onStatusChanged(widget.laporan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Laporan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _sendToWhatsApp(context, widget.laporan),
            icon: const Icon(Icons.chat),
            tooltip: 'Kirim ke WhatsApp',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan status
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.laporan['judul_pengaduan'],
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: _showStatusDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                  widget.laporan['status'] ?? 'Menunggu'),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getStatusIcon(widget.laporan['status']),
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.laporan['status'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Chip(
                          label: Text(widget.laporan['kategori']),
                          backgroundColor: Colors.blue[100],
                        ),
                        const Spacer(),
                        Text(
                          widget.laporan['tanggal'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informasi detail
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informasi Laporan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow('Deskripsi', widget.laporan['deskripsi']),
                    const SizedBox(height: 12),
                    _buildDetailRow('Alamat', widget.laporan['alamat']),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                        'Instansi Terkait', widget.laporan['kategori']),
                    const SizedBox(height: 12),
                    _buildDetailRow('Dikirim Anonim',
                        widget.laporan['is_anonim'] == '1' ? 'Ya' : 'Tidak'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Informasi detail
            if (widget.laporan['lampiran'] != null)
              Container(
                width: double.infinity,
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lampiran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final lampiran = widget.laporan['lampiran'];
                            if (lampiran != null &&
                                lampiran.toString().isNotEmpty) {
                              final url = Uri.parse(
                                  '${EndPoint.url}uploads/lampiran/$lampiran');
                              if (!await launchUrl(url,
                                  mode: LaunchMode.externalApplication)) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Tidak dapat membuka lampiran'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lampiran tidak tersedia'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Lihat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Foto laporan (jika ada)
            if (widget.laporan['foto'] != null &&
                widget.laporan['foto'].toString().isNotEmpty)
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Foto Laporan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(
                              EndPoint.url +
                                  'uploads/foto/${widget.laporan['foto']}',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: simpanStatus,
                    icon: const Icon(Icons.edit),
                    label: const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendToWhatsApp(context, widget.laporan),
                    icon: const Icon(Icons.chat),
                    label: const Text('Hubungi Instansi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
