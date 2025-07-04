import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:penganduan_app/endPoint.dart';

// Kelas untuk halaman form pengaduan baru
class BuatPengaduanPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const BuatPengaduanPage({this.userData, super.key});

  @override
  State<BuatPengaduanPage> createState() => _BuatPengaduanPageState();
}

class _BuatPengaduanPageState extends State<BuatPengaduanPage> {
  // Controller untuk setiap input field
  final _judulController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String _latitude = "";
  String _longitude = "";
  final _lokasiController = TextEditingController();

  // Form key untuk validasi
  final _formKey = GlobalKey<FormState>();

  // Kategori pengaduan yang tersedia
  final List<String> _kategoriList = [
    'Infrastruktur',
    'Pelayanan Publik',
    'Lingkungan',
    'Keamanan',
    'Lainnya',
  ];

  // Variabel untuk menyimpan nilai yang dipilih
  String _selectedKategori = 'Infrastruktur';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isAnonymous = false;
  bool _isGettingLocation = false;
  PlatformFile? _selectedFile;
  File? _imageFile;

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Fungsi untuk memilih waktu
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Fungsi untuk mendapatkan lokasi saat ini
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // 1. Cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak oleh pengguna.');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Izin lokasi ditolak secara permanen. Silakan aktifkan di pengaturan aplikasi.');
      }

      // 2. Dapatkan posisi saat ini
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Konversi koordinat ke alamat (Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address =
            '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}, ${place.postalCode}';
        _latitude = position.latitude.toString();
        _longitude = position.longitude.toString();
        _lokasiController.text = address;
      } else {
        throw Exception('Tidak dapat menemukan alamat dari lokasi saat ini.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Gagal mendapatkan lokasi: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _ambilFotoDariKamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _kirimPengaduan() async {
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse(EndPoint.url+"pengaduan.php"); // Ganti dengan URL server-mu
    final request = http.MultipartRequest('POST', uri);

    final id_user = widget.userData?["id"];

    if(id_user != null){
      request.fields['id_user'] = id_user.toString();
    }
    request.fields['judul_pengaduan'] = _judulController.text;
    request.fields['kategori'] = _selectedKategori;
    request.fields['deskripsi'] = _deskripsiController.text;
    request.fields['latitude'] = _latitude;
    request.fields['longitude'] = _longitude;
    request.fields['alamat'] = _lokasiController.text;
    request.fields['jam'] = _selectedTime.format(context);
    request.fields['tanggal'] =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

    // Tambah lampiran
    if (_selectedFile != null && _selectedFile!.path != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'lampiran',
        _selectedFile!.path!,
      ));
    }

    // Tambah foto
    if (_imageFile != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'foto',
        _imageFile!.path,
      ));
    }
    request.fields['is_anonim'] = _isAnonymous ? '1' : '0';

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        if (data['status']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message']), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(data['message']), backgroundColor: Colors.red),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal mengirim pengaduan.'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    // Membersihkan controller ketika widget dihapus
    _judulController.dispose();
    _deskripsiController.dispose();
    _lokasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pengaduan Baru'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul form
                    const Text(
                      'Sampaikan Pengaduan Anda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Judul pengaduan
                    TextFormField(
                      controller: _judulController,
                      decoration: InputDecoration(
                        labelText: 'Judul Pengaduan',
                        hintText: 'Masukkan judul singkat pengaduan',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Judul pengaduan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Kategori pengaduan (dropdown)
                    DropdownButtonFormField<String>(
                      value: _selectedKategori,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      items: _kategoriList.map((String kategori) {
                        return DropdownMenuItem<String>(
                          value: kategori,
                          child: Text(kategori),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedKategori = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Deskripsi pengaduan
                    TextFormField(
                      controller: _deskripsiController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Pengaduan',
                        hintText: 'Jelaskan detail pengaduan Anda',
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 80),
                          child: Icon(Icons.description),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi pengaduan tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Lokasi kejadian
                    TextFormField(
                      controller: _lokasiController,
                      decoration: InputDecoration(
                        labelText: 'Lokasi Kejadian',
                        hintText: 'Masukkan alamat atau lokasi kejadian',
                        prefixIcon: const Icon(Icons.location_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        suffixIcon: _isGettingLocation
                            ? Transform.scale(
                                scale: 0.5,
                                child: const CircularProgressIndicator(),
                              )
                            : IconButton(
                                icon: const Icon(Icons.my_location),
                                onPressed: _getCurrentLocation,
                                tooltip: 'Gunakan Lokasi Saat Ini',
                              ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Lokasi kejadian tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Waktu kejadian
                    InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Waktu Kejadian',
                          prefixIcon: const Icon(Icons.access_time),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedTime.format(context),
                            ),
                            IconButton(
                              icon:
                                  const Icon(Icons.update, color: Colors.blue),
                              onPressed: () {
                                setState(() {
                                  _selectedTime = TimeOfDay.now();
                                });
                              },
                              tooltip: 'Gunakan Waktu Sekarang',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tanggal kejadian
                    InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Tanggal Kejadian',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Lampiran (attachment)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Lampiran',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();

                            if (result != null && result.files.isNotEmpty) {
                              setState(() {
                                _selectedFile = result.files.first;
                              });
                            }
                          },
                          icon: const Icon(Icons.attach_file),
                          label: const Text('Tambah Lampiran'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        if (_selectedFile != null)
                          Text(
                            'File dipilih: ${_selectedFile!.name}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                        const Text(
                          'Foto',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: _ambilFotoDariKamera,
                          icon: Icon(Icons.camera_alt),
                          label: Text("Ambil Foto"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_imageFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imageFile!,
                              width: double.infinity,
                              height: 250,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    ...(widget.userData != null
                        ? [
                            // Opsi pengaduan anonim
                            SwitchListTile(
                              title:
                                   Text('Kirim sebagai pengaduan anonim'),
                              subtitle: const Text(
                                'Identitas Anda tidak akan ditampilkan',
                              ),
                              value: _isAnonymous,
                              activeColor: Colors.blue,
                              contentPadding: EdgeInsets.zero,
                              onChanged: (bool value) {
                                setState(() {
                                  _isAnonymous = value;
                                });
                              },
                            ),
                          ]
                        : []),
                    const SizedBox(height: 30),

                    // Tombol submit
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _kirimPengaduan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Kirim Pengaduan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
