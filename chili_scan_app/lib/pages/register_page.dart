import 'package:chili_scan_app/common/constants/colors.dart';
import 'package:chili_scan_app/common/utils/toast.dart';
import 'package:chili_scan_app/models/universal_result.dart';
import 'package:chili_scan_app/providers/auth_notifier.dart';
import 'package:chili_scan_app/widgets/form_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      Toast.error(
        title: "Validation Error",
        message: "Please fill in all fields.",
      );
      return;
    }

    final response = await ref
        .read(authNotifierProvider.notifier)
        .register(email: email, password: password, name: name);

    if (response is AppFailure) {
      Toast.error(title: "Registration Failed", message: response.message);
    } else {
      Toast.success(
        title: "Success",
        message: "Registration successful. Please log in.",
      );
      context.replace('/login');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final auth = ref.watch(authNotifierProvider);

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
                            label: 'Name',
                            hintText: 'Masukkan nama lengkap',
                            controller: _nameController,
                          ),
                          FormInput(
                            label: 'Email',
                            hintText: 'Masukkan alamat email',
                            controller: _emailController,
                          ),
                          FormInput(
                            label: 'Password',
                            hintText: 'Buat password',
                            isPassword: true,
                            controller: _passwordController,
                          ),

                          Column(
                            spacing: 12,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  if (!auth.isLoading) {
                                    _register();
                                  }
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
                                child: auth.isLoading
                                    ? CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      )
                                    : const Text('Daftar Sekarang'),
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
