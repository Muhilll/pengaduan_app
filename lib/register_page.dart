import 'package:flutter/material.dart';
import 'package:penganduan_app/FormLogin.dart';
import 'package:http/http.dart' as http;
import 'package:penganduan_app/ProfilUser.dart';
import 'package:penganduan_app/endPoint.dart';
import 'dart:convert';

import 'package:penganduan_app/main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String _selectedRole = 'Pengguna';

  final List<String> _roles = [
    'Pengguna',
    'AdminSuper',
    'AdminInfrastruktur',
    'AdminPelayanan',
    'AdminKeamanan',
    'AdminLingkungan',
  ];

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse(EndPoint.url+"register.php"), // emulator pakai 10.0.2.2
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "nama": _namaController.text,
        "email": _emailController.text,
        "no_hp": _noHpController.text,
        "alamat": _alamatController.text,
        "username": _usernameController.text,
        "password": _passwordController.text,
        "role" : _selectedRole
      }),
    );

    final result = jsonDecode(response.body);

    setState(() {
      _isLoading = false;
    });

    if (result['status'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registrasi berhasil")),
      );

      // Pindah ke halaman MyApp
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal: ${result['message']}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade50,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Registrasi',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _namaController,
                        label: 'Nama Lengkap',
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _noHpController,
                        label: 'No. HP',
                        icon: Icons.phone,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _alamatController,
                        label: 'Alamat',
                        icon: Icons.home,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.account_circle,
                      ),
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade200,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          dropdownColor: Colors.blue.shade200,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Daftar sebagai',
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            prefixIcon: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                            ),
                          ),
                          iconEnabledColor: Colors.white,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          items: _roles
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ))
                              .toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedRole = newValue;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.blue),
                              )
                            : const Text('Registrasi',
                                style: TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Kembali ke halaman login
                        },
                        child: const Text(
                          'Sudah punya akun? Login',
                          style: TextStyle(color: Colors.white),
                        ),
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
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !_isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.blue.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
