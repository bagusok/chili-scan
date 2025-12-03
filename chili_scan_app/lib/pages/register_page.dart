import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:chili_scan_app/widgets/form_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreeToPolicy = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9F7FF), Color(0xFFFDF8F4)],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  spacing: 24,
                  children: [
                    Column(
                      spacing: 12,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryColor.withAlpha(80),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.spa_rounded,
                            size: 40,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Buat Akun Chili Scan',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Registrasi sekarang untuk memantau kualitas cabai dan menyimpan riwayat pemindaianmu.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x15000000),
                            offset: Offset(0, 14),
                            blurRadius: 32,
                          ),
                        ],
                      ),
                      child: Column(
                        spacing: 20,
                        children: [
                          FormInput(
                            label: 'Nama Lengkap',
                            hintText: 'Masukkan nama lengkap',
                            controller: _nameController,
                          ),
                          FormInput(
                            label: 'Email',
                            hintText: 'Masukkan alamat email',
                            controller: _emailController,
                          ),
                          FormInput(
                            label: 'Username',
                            hintText: 'Masukkan username',
                            controller: _usernameController,
                          ),
                          FormInput(
                            label: 'Password',
                            hintText: 'Buat password',
                            isPassword: true,
                            controller: _passwordController,
                          ),
                          FormInput(
                            label: 'Konfirmasi Password',
                            hintText: 'Ulangi password',
                            isPassword: true,
                            controller: _confirmPasswordController,
                          ),
                          Row(
                            children: [
                              Checkbox(
                                value: _agreeToPolicy,
                                onChanged: (value) {
                                  if (value == null) return;
                                  setState(() => _agreeToPolicy = value);
                                },
                              ),
                              Expanded(
                                child: Text(
                                  'Saya menyetujui kebijakan privasi dan ketentuan penggunaan Chili Scan.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            spacing: 12,
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('Daftar Sekarang'),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  context.replace('/login');
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  foregroundColor: primaryColor,
                                  side: BorderSide(
                                    color: primaryColor.withValues(alpha: 40),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Sudah punya akun? Masuk'),
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
        ),
      ),
    );
  }
}
