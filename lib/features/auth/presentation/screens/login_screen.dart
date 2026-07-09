import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/theme/senior_system_ui.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_input.dart';
import 'package:mobile/core/widgets/senior_logo.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/auth/domain/auth_exceptions.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/providers/biometric_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  // TODO(dev): remover credenciais de teste antes de publicar; ao remover, re-ativar o
  // teste 'redireciona para home quando autenticado' em test/widget_test.dart
  final _emailController = TextEditingController(text: 'senior@teste.com');
  final _passwordController = TextEditingController(text: '123456');
  var _rememberMe = true;

  static const _formHorizontalPadding = 20.0;

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

  Future<void> _submitGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    // Cancelamento do seletor de contas não é um erro — ignora em silêncio.
    if (state.hasError && state.error is! AuthCancelledException) {
      showSeniorToast(
        context,
        title: 'Não foi possível entrar com o Google',
        message: state.error.toString().replaceFirst('Exception: ', ''),
        variant: SeniorToastVariant.danger,
      );
    }
  }

  Future<void> _submitBiometric() async {
    final controller = ref.read(biometricControllerProvider.notifier);
    final success = await controller.authenticateForLogin();

    if (!mounted) return;

    if (success) {
      // A sessão Firebase já está persistida localmente; o auth guard redireciona.
      context.go(AppRoutes.home);
    } else {
      showSeniorToast(
        context,
        title: 'Não foi possível entrar',
        message: 'Autenticação biométrica cancelada ou falhada.',
        variant: SeniorToastVariant.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAction = ref.watch(authControllerProvider);
    final isLoading = authAction.isLoading;

    final biometricState = ref.watch(biometricControllerProvider).asData?.value;
    final showBiometric =
        biometricState != null &&
        biometricState.isAvailable &&
        biometricState.isEnabled;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SeniorSystemUi.loginOverlay,
      child: Scaffold(
        backgroundColor: AppColors.slate50,
        body: SafeArea(
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  children: [
                    const SeniorLogo(size: 64, useGradient: false),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Bem-vindo de volta',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Entre na sua conta SeniorEase',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: _formHorizontalPadding,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.slate500,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push(AppRoutes.forgotPassword),
                              child: Text(
                                'Esqueci minha senha',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SeniorButton(
                          label: 'Entrar',
                          icon: Icons.login,
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _submit,
                        ),
                        if (showBiometric) ...[
                          const SizedBox(height: AppSpacing.md),
                          SeniorButton(
                            label: 'Entrar com biometria',
                            variant: SeniorButtonVariant.outline,
                            icon: Icons.fingerprint,
                            onPressed: isLoading ? null : _submitBiometric,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              child: Text(
                                'ou',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SeniorButton(
                          label: 'Entrar com Google',
                          variant: SeniorButtonVariant.secondary,
                          customForegroundColor: AppColors.slate600,
                          leading: Image.asset(
                            'assets/images/google_logo.png',
                            width: 22,
                            height: 22,
                          ),
                          onPressed: isLoading ? null : _submitGoogle,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SeniorButton(
                          label: 'Criar conta',
                          variant: SeniorButtonVariant.secondary,
                          onPressed: isLoading ? null : () => context.push(AppRoutes.register),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text.rich(
                          TextSpan(
                            style: Theme.of(context).textTheme.labelSmall,
                            children: const [
                              TextSpan(text: 'Precisa de ajuda? Ligue para '),
                              TextSpan(
                                text: '0800-SENIOR',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
