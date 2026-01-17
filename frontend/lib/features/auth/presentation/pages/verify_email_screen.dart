// ignore_for_file: deprecated_member_use, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String? userId;
  final String? email;

  const VerifyEmailScreen({super.key, this.userId, this.email});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  bool _isResending = false;
  int _resendTimer = 0;

  @override
  void initState() {
    super.initState();
    // Add listeners to auto-advance focus
    for (int i = 0; i < 6; i++) {
      _controllers[i].addListener(() {
        if (_controllers[i].text.length == 1 && i < 5) {
          _focusNodes[i + 1].requestFocus();
        }
        // Auto-submit when all fields are filled
        if (_isCodeComplete()) {
          _verifyCode();
        }
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool _isCodeComplete() {
    return _controllers.every((c) => c.text.isNotEmpty);
  }

  String _getCode() {
    return _controllers.map((c) => c.text).join();
  }

  void _verifyCode() {
    final code = _getCode();
    if (code.length == 6 && widget.userId != null) {
      context.read<AuthBloc>().add(
        Verify2FARequested(userId: widget.userId!, totpCode: code),
      );
    }
  }

  void _resendCode() async {
    if (_resendTimer > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    // Simulate resend
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isResending = false;
      _resendTimer = 60;
    });

    // Start countdown
    _startResendTimer();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code resent!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  void _startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
        return _resendTimer > 0;
      }
      return false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            context.go('/home');
          } else if (state.status == AuthStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
            // Clear the code fields on error
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 1),
                  // Icon
                  _buildIcon(),
                  const SizedBox(height: 32),
                  // Title
                  const Text(
                    'Check your email',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    'We\'ve sent a 6-digit code to your email.\nPlease enter it below to continue.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),
                  if (widget.email != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.email!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                  // Verification Code Label
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Verification Code',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Code Input Fields
                  _buildCodeInputFields(),
                  const SizedBox(height: 32),
                  // Verify Button
                  _buildVerifyButton(state),
                  const SizedBox(height: 24),
                  // Resend Code
                  _buildResendButton(),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Phone icon
          Icon(
            Icons.smartphone,
            size: 40,
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.8),
          ),
          // Stars decoration
          Positioned(top: 12, left: 12, child: _buildStar(8)),
          Positioned(top: 8, right: 20, child: _buildStar(6)),
          Positioned(bottom: 16, right: 12, child: _buildStar(10)),
        ],
      ),
    );
  }

  Widget _buildStar(double size) {
    return Icon(Icons.star, size: size, color: const Color(0xFF3B82F6));
  }

  Widget _buildCodeInputFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++) _buildCodeField(i),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            '-',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ),
        for (int i = 3; i < 6; i++) _buildCodeField(i),
      ],
    );
  }

  Widget _buildCodeField(int index) {
    return Container(
      width: 48,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFF1E3A5F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
        ),
        onChanged: (value) {
          if (value.isEmpty && index > 0) {
            // Handle backspace - move to previous field
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Widget _buildVerifyButton(AuthState state) {
    final isLoading = state.status == AuthStatus.loading;
    final isComplete = _isCodeComplete();

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading || !isComplete ? null : _verifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFEF4444).withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Verify Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildResendButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive a code? ',
          style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
        ),
        GestureDetector(
          onTap: _resendTimer == 0 ? _resendCode : null,
          child: Text(
            _resendTimer > 0 ? 'Resend in ${_resendTimer}s' : 'Resend Code',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _resendTimer > 0
                  ? Colors.white.withOpacity(0.4)
                  : const Color(0xFFEF4444),
            ),
          ),
        ),
      ],
    );
  }
}
