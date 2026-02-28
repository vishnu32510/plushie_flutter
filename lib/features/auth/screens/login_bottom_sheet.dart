import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plushie_yourself/core/services/auth_service.dart';
import 'package:plushie_yourself/modules/theme/app_colors.dart';

class LoginBottomSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const LoginBottomSheet({super.key, required this.onSuccess});

  static Future<void> show(BuildContext context,
      {required VoidCallback onSuccess}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LoginBottomSheet(onSuccess: onSuccess),
    );
  }

  @override
  State<LoginBottomSheet> createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final user = await AuthService.signInWithGoogle();
    if (!mounted) return;
    setState(() => _loading = false);
    if (user != null) {
      Navigator.pop(context);
      widget.onSuccess();
    } else {
      setState(() => _error = 'Google sign-in was cancelled.');
    }
  }

  Future<void> _handleEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Please enter email and password.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = _isSignUp
          ? await AuthService.signUpWithEmail(email, password)
          : await AuthService.signInWithEmail(email, password);
      if (!mounted) return;
      setState(() => _loading = false);
      if (user != null) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AuthService.friendlyError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.subtleGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header
          const Text('🧸', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'Sign in to create\nyour plushie',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.warmBrown,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Free to try — no credit card needed',
            style: TextStyle(fontSize: 13, color: AppColors.warmBrownLight),
          ),
          const SizedBox(height: 28),

          // Google button
          _GoogleButton(onTap: _loading ? null : _handleGoogle),
          const SizedBox(height: 16),

          // Divider
          Row(children: [
            const Expanded(child: Divider(color: AppColors.subtleGray)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('or',
                  style: TextStyle(
                      color: AppColors.warmBrownLight, fontSize: 13)),
            ),
            const Expanded(child: Divider(color: AppColors.subtleGray)),
          ]),
          const SizedBox(height: 16),

          // Email field
          _PlushieTextField(
            controller: _emailController,
            hint: 'Email address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),

          // Password field
          _PlushieTextField(
            controller: _passwordController,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: true,
          ),

          // Error
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: AppColors.errorRed, fontSize: 13),
            ),
          ],
          const SizedBox(height: 20),

          // Email action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _loading ? null : _handleEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warmBrown,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _isSignUp ? 'Create account' : 'Sign in',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Toggle sign in / sign up
          GestureDetector(
            onTap: () => setState(() {
              _isSignUp = !_isSignUp;
              _error = null;
            }),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                    fontSize: 13, color: AppColors.warmBrownLight),
                children: [
                  TextSpan(
                      text: _isSignUp
                          ? 'Already have an account? '
                          : "Don't have an account? "),
                  TextSpan(
                    text: _isSignUp ? 'Sign in' : 'Sign up',
                    style: const TextStyle(
                      color: AppColors.warmAmber,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _GoogleButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: AppColors.subtleGray, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google G icon
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Text(
                'G',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4285F4),
                  height: 1.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C4043),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlushieTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  const _PlushieTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.warmBrown, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.warmBrownLight, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.warmBrownLight, size: 20),
        filled: true,
        fillColor: AppColors.warmCream,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.subtleGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.subtleGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide:
              const BorderSide(color: AppColors.warmAmber, width: 1.5),
        ),
      ),
    );
  }
}
