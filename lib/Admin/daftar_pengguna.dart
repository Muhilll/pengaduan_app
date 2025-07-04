import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:penganduan_app/endPoint.dart';

class DaftarPengguna extends StatefulWidget {
  const DaftarPengguna({super.key});

  @override
  State<DaftarPengguna> createState() => _DaftarPenggunaState();
}

class _DaftarPenggunaState extends State<DaftarPengguna> {
  List<dynamic> daftarPengguna = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPengguna();
  }

  Future<void> fetchPengguna() async {
    try {
      final response =
          await http.get(Uri.parse('${EndPoint.url}get_users.php'));

      final data = jsonDecode(response.body);
      if (data['status']) {
        setState(() {
          daftarPengguna = data['data'];
          isLoading = false;
        });
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red,
        ));
      }
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengguna Terdaftar'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: daftarPengguna.length,
              itemBuilder: (context, index) {
                final pengguna = daftarPengguna[index];
                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        pengguna['nama']?[0].toUpperCase() ?? '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    title: Text(pengguna['nama'] ?? ''),
                    subtitle: Text(pengguna['email'] ?? ''),
                  ),
                );
              },
            ),
    );
  }
}