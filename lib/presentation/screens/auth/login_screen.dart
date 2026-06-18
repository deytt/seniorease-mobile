import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/presentation/providers/auth_provider.dart';
import 'package:mobile/presentation/theme/app_colors.dart';
import 'package:mobile/presentation/theme/app_spacing.dart';
import 'package:mobile/presentation/theme/app_theme.dart';
import 'package:mobile/presentation/widgets/ui/senior_button.dart';
import 'package:mobile/presentation/widgets/ui/senior_input.dart';
import 'package:mobile/presentation/widgets/ui/senior_logo.dart';
import 'package:mobile/presentation/widgets/ui/senior_toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      showSeniorToast(
        context,
        title: 'Não foi possível entrar',
        message: state.error.toString().replaceFirst('Exception: ', ''),
        variant: SeniorToastVariant.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAction = ref.watch(authControllerProvider);
    final isLoading = authAction.isLoading;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.xl),
                const Center(child: SeniorLogo()),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Bem-vindo de volta',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Entre na sua conta SeniorEase',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SeniorInput(
                  controller: _emailController,
                  label: 'E-mail',
                  hint: 'seu@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.email_outlined,
                  autocorrect: false,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe seu e-mail';
                    }
                    if (!value.contains('@')) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                SeniorInput(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Digite sua senha',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  prefixIcon: Icons.lock_outline,
                  onSubmitted: (_) => _submit(),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe sua senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Semantics(
                      label: 'Lembrar de mim',
                      child: SizedBox(
                        width: AppTheme.minTouchTarget,
                        height: AppTheme.minTouchTarget,
                        child: Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Lembrar de mim',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.slate900,
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.forgotPassword),
                      child: const Text('Esqueci minha senha'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SeniorButton(
                  label: 'Entrar',
                  icon: Icons.arrow_forward,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submit,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'ou',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SeniorButton(
                  label: 'Criar conta',
                  variant: SeniorButtonVariant.secondary,
                  onPressed: isLoading ? null : () => context.push(AppRoutes.register),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Precisa de ajuda? Ligue para 0800-SENIOR',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
