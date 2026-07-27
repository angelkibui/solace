import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../../../core/widgets/solace_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// D11 — forgot-password email input + confirmation. This screen owns its
/// own "email sent" UI rather than relying on AuthBloc's state shape,
/// since AuthError/AuthUnauthenticated aren't distinctive enough on their
/// own to tell "reset email sent" apart from "nothing happened yet".
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(PasswordResetRequested(_emailController.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
            } else if (state is AuthUnauthenticated && !_emailSent && _emailController.text.isNotEmpty) {
              // A successful reset call routes AuthBloc back through
              // AuthUnauthenticated — treat that (while this screen is the
              // one that just fired the request) as "email sent".
              setState(() => _emailSent = true);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _emailSent ? _buildConfirmation() : _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Forgot your password?', style: AppTextStyles.headingMedium),
          const SizedBox(height: 8),
          Text(
            "Enter the email on your account and we'll send you a link to reset it.",
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 28),
          SolaceTextField(
            label: 'Email',
            hint: 'you@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          const SizedBox(height: 24),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return SolaceButton(
                label: 'Send Reset Link',
                isLoading: state is AuthLoading,
                onPressed: _submit,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.mark_email_read_outlined, color: AppColors.success, size: 56),
        const SizedBox(height: 16),
        Text('Check your email', style: AppTextStyles.headingMedium, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(
          "We've sent a password reset link to ${_emailController.text.trim()}.",
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SolaceButton(
          label: 'Back to Login',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
