// lib/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../penjual/beranda_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<Map<String, String>> _penjualAccounts = [
    {'email': 'admin@butik.com', 'password': 'admin123', 'name': 'Admin Butik'},
    {'email': 'ani@butik.com', 'password': '123456', 'name': 'Ani'},
  ];

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(seconds: 1));

      Map<String, String>? user = _penjualAccounts.firstWhere(
        (user) => user['email'] == _emailController.text.trim() && user['password'] == _passwordController.text,
        orElse: () => {},
      );

      setState(() => _isLoading = false);

      if (user.isNotEmpty && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BerandaScreen(
              userName: user['name'] ?? '',
              userEmail: user['email'] ?? '',
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email atau password salah!'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF803033), Color(0xFFD8A5A8), Color(0xFFF5ECEA)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(flex: 2),
                          
                          // Logo
                          Image.asset(
                            'assets/images/logoo.png',
                            width: 110,
                            height: 110,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.store_outlined, size: 100, color: Colors.white);
                            },
                          ),
                          
                          const SizedBox(height: 15),
                          
                          // Welcome Text
                          Text(
                            'Selamat Datang',
                            style: GoogleFonts.playfairDisplay(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF803033),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'Masuk untuk mengelola butik Anda',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          const SizedBox(height: 48),
                          
                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Email Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'EMAIL',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                                      decoration: InputDecoration(
                                        hintText: 'Masukan email anda',
                                        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 14),
                                        prefixIcon: Icon(Icons.email_outlined, color: const Color(0xFF803033), size: 22),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: const Color(0xFF803033).withOpacity(0.5), width: 1.5),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
                                        if (!value.contains('@') || !value.contains('.')) return 'Email tidak valid';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Password Field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'KATA SANDI',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87),
                                      decoration: InputDecoration(
                                        hintText: 'Masukan kata sandi anda',
                                        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 14),
                                        prefixIcon: Icon(Icons.lock_outline, color: const Color(0xFF803033), size: 22),
                                        suffixIcon: IconButton(
                                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey.shade500, size: 20),
                                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                        ),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(14),
                                          borderSide: BorderSide(color: const Color(0xFF803033).withOpacity(0.5), width: 1.5),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                                        if (value.length < 6) return 'Password minimal 6 karakter';
                                        return null;
                                      },
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // Login Button
                                _isLoading
                                    ? Container(
                                        height: 54,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(colors: [Color(0xFF803033), Color(0xFFB85C5F)]),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Center(
                                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
                                        ),
                                      )
                                    : ElevatedButton(
                                        onPressed: _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF803033),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 54),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          elevation: 0,
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('Masuk', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.arrow_forward, size: 18),
                                          ],
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Info Text
                          Text(
                            'Akun penjual dibuat oleh administrator.',
                            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w500),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Footer
                          Text(
                            'SIBU © 2026',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.white60, letterSpacing: 0.8),
                          ),
                          
                          const Spacer(flex: 2),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}