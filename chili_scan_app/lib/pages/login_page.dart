import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:chili_scan_app/widgets/form_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
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
                constraints: const BoxConstraints(maxWidth: 420),
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
                            color: primaryColor.withValues(alpha: 20),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.qr_code_scanner_rounded,
                            size: 40,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'Welcome Back',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Masuk untuk melanjutkan memindai cabai dan memantau riwayat kamu.',
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
                            label: 'Username',
                            hintText: 'Masukkan username',
                            controller: _usernameController,
                          ),
                          FormInput(
                            label: 'Password',
                            hintText: 'Masukkan password',
                            isPassword: true,
                            controller: _passwordController,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Lupa Password?'),
                            ),
                          ),
                          Column(
                            spacing: 12,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  context.replace('/home');
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text('Masuk'),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  context.go('/register');
                                },
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 52),
                                  foregroundColor: primaryColor,
                                  side: BorderSide(color: primaryColor),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Daftar Akun Baru'),
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
