import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:surat_mobile_sukorame/services/auth_service.dart';
import 'package:surat_mobile_sukorame/theme/app_theme.dart';
import 'package:surat_mobile_sukorame/widgets/common_widgets.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _codeSent = false;
  String? _verificationId;
  String? _errorMessage;

  void _verifyPhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: _phoneController.text,
        onVerificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _signInWithCredential(credential);
        },
        onVerificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _errorMessage = e.message ?? 'Verifikasi gagal';
          });
        },
        onCodeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _codeSent = true;
            _isLoading = false;
          });
        },
        onCodeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    }
  }

  void _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Kode OTP tidak valid';
      });
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      await _authService.signInWithPhoneNumber(credential);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Login gagal: $e';
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login dengan Nomor HP'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xl),
              Text(
                _codeSent ? 'Masukkan Kode OTP' : 'Masukkan Nomor HP',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _codeSent
                    ? 'Kode OTP telah dikirim ke nomor ${_phoneController.text}'
                    : 'Kami akan mengirimkan kode OTP ke nomor HP Anda',
                style: AppTextStyles.body1.copyWith(color: AppTheme.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (!_codeSent)
                AppTextField(
                  label: 'Nomor HP',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor HP tidak boleh kosong';
                    }
                    if (!value.startsWith('+62')) {
                      return 'Nomor HP harus dimulai dengan +62';
                    }
                    return null;
                  },
                ),
              if (_codeSent)
                AppTextField(
                  label: 'Kode OTP',
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.lock_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode OTP tidak boleh kosong';
                    }
                    if (value.length != 6) {
                      return 'Kode OTP harus 6 digit';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                text: _codeSent ? 'Verifikasi OTP' : 'Kirim Kode OTP',
                onPressed: _codeSent ? _verifyOTP : _verifyPhone,
                isLoading: _isLoading,
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  style: AppTextStyles.body2.copyWith(color: AppTheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}