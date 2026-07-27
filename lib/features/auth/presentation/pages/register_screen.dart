import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/solace_button.dart';
import '../../../../core/widgets/solace_text_field.dart';
import '../../../onboarding/presentation/cubit/onboarding_cubit.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onSwitchToLogin;

  const RegisterScreen({super.key, this.onSwitchToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _aliasController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  bool _termsTouched = false;

  @override
  void initState() {
    super.initState();
    final onboardingAlias = context.read<OnboardingCubit>().state.alias;
    _aliasController = TextEditingController(text: onboardingAlias ?? '');
  }

  @override
  void dispose() {
    _aliasController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _termsTouched = true);
    final formValid = _formKey.currentState!.validate();
    if (!formValid || !_agreedToTerms) return;

    context.read<AuthBloc>().add(
          RegisterRequested(
            alias: _aliasController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            preferences: context.read<OnboardingCubit>().state.selectedConcerns.toList(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error));
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Your alias is what others see — never your real name.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SolaceTextField(
                    label: 'Alias',
                    hint: 'Your anonymous display name',
                    controller: _aliasController,
                    validator: Validators.alias,
                    prefixIcon:
                        const Icon(Icons.face_retouching_natural_rounded),
                  ),
                  const SizedBox(height: 16),
                  SolaceTextField(
                    label: 'Email',
                    hint: 'you@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  const SizedBox(height: 16),
                  SolaceTextField(
                    label: 'Password',
                    hint: 'At least 8 characters',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: Validators.password,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SolaceTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    obscureText: _obscurePassword,
                    validator: (v) =>
                        Validators.confirmPassword(v, _passwordController.text),
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreedToTerms,
                        onChanged: (v) =>
                            setState(() => _agreedToTerms = v ?? false),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy.',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_termsTouched && !_agreedToTerms)
                    Padding(
                      padding: const EdgeInsets.only(left: 12, bottom: 8),
                      child: Text(
                        'Please accept the terms to continue.',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.error),
                      ),
                    ),
                  const SizedBox(height: 12),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SolaceButton(
                        label: 'Create Account',
                        isLoading: state is AuthLoading,
                        onPressed: _submit,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: AppTextStyles.bodyMedium),
                      GestureDetector(
                        onTap: widget.onSwitchToLogin ??
                            () => Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                ),
                        child: Text(
                          'Log In',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
