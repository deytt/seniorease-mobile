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
import 'package:mobile/features/auth/domain/entities/login_preferences.dart';
import 'package:mobile/features/auth/domain/usecases/save_login_preferences_use_case.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/providers/login_preferences_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  var _rememberMe = true;

  /// E-mail lembrado do último acesso (null quando não há identidade guardada).
  String? _rememberedEmail;

  /// Método do último acesso — usado para destacar o botão correspondente.
  LoginMethod? _lastMethod;

  /// Guardado após o carregamento para persistir sem depender do `ref` (o
  /// widget pode ser desmontado pelo redirect logo após o login bem-sucedido).
  SaveLoginPreferencesUseCase? _saveUseCase;

  static const _formHorizontalPadding = 20.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final getUseCase =
        await ref.read(getLoginPreferencesUseCaseProvider.future);
    _saveUseCase = await ref.read(saveLoginPreferencesUseCaseProvider.future);

    final prefs = await getUseCase.call();
    if (!mounted) return;

    setState(() {
      _rememberMe = prefs.rememberMe;
      if (prefs.hasRememberedIdentity) {
        _emailController.text = prefs.lastEmail!;
        _rememberedEmail = prefs.lastEmail;
        _lastMethod = prefs.lastMethod;
      }
    });
  }

  Future<void> _persistPreferences({
    required String email,
    required LoginMethod method,
  }) async {
    final useCase = _saveUseCase;
    if (useCase == null) return;
    await useCase.call(
      LoginPreferences(
        rememberMe: _rememberMe,
        lastEmail: _rememberMe ? email : null,
        lastMethod: _rememberMe ? method : null,
      ),
    );
  }

  /// Limpa a identidade lembrada e devolve o foco ao campo de e-mail.
  Future<void> _useAnotherAccount() async {
    setState(() {
      _emailController.clear();
      _passwordController.clear();
      _rememberedEmail = null;
      _lastMethod = null;
    });
    await _saveUseCase?.call(LoginPreferences(rememberMe: _rememberMe));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();

    await ref.read(authControllerProvider.notifier).signIn(
          email: email,
          password: _passwordController.text,
        );

    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      if (!mounted) return;
      showSeniorToast(
        context,
        title: 'Não foi possível entrar',
        message: state.error.toString().replaceFirst('Exception: ', ''),
        variant: SeniorToastVariant.danger,
      );
      return;
    }

    await _persistPreferences(email: email, method: LoginMethod.email);
  }

  Future<void> _submitGoogle() async {
    await ref.read(authControllerProvider.notifier).signInWithGoogle();

    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      // Cancelamento do seletor de contas não é um erro — ignora em silêncio.
      if (state.error is! AuthCancelledException && mounted) {
        showSeniorToast(
          context,
          title: 'Não foi possível entrar com o Google',
          message: state.error.toString().replaceFirst('Exception: ', ''),
          variant: SeniorToastVariant.danger,
        );
      }
      return;
    }

    final email = ref.read(authStateProvider).asData?.value?.email;
    if (email != null && email.isNotEmpty) {
      await _persistPreferences(email: email, method: LoginMethod.google);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authAction = ref.watch(authControllerProvider);
    final isLoading = authAction.isLoading;

    final hasRemembered = _rememberedEmail != null;
    final prefersGoogle = _lastMethod == LoginMethod.google;

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
                      hasRemembered
                          ? 'Confirme para entrar na sua conta'
                          : 'Entre na sua conta SeniorEase',
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
                        if (hasRemembered) ...[
                          _RememberedAccountCard(
                            email: _rememberedEmail!,
                            method: _lastMethod,
                            onUseAnotherAccount:
                                isLoading ? null : _useAnotherAccount,
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        SeniorInput(
                          controller: _emailController,
                          label: 'E-mail',
                          hint: 'seu@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.email_outlined,
                          autocorrect: false,
                          onSubmitted: (_) => _passwordFocus.requestFocus(),
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
                          focusNode: _passwordFocus,
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
                          variant: prefersGoogle
                              ? SeniorButtonVariant.outline
                              : SeniorButtonVariant.primary,
                          isLoading: isLoading && !prefersGoogle,
                          onPressed: isLoading ? null : _submit,
                        ),
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
                          label: prefersGoogle
                              ? 'Continuar com Google'
                              : 'Entrar com Google',
                          variant: prefersGoogle
                              ? SeniorButtonVariant.primary
                              : SeniorButtonVariant.secondary,
                          customForegroundColor:
                              prefersGoogle ? null : AppColors.slate600,
                          isLoading: isLoading && prefersGoogle,
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

/// Card que mostra a conta lembrada com opção de trocar de conta.
class _RememberedAccountCard extends StatelessWidget {
  const _RememberedAccountCard({
    required this.email,
    required this.method,
    required this.onUseAnotherAccount,
  });

  final String email;
  final LoginMethod? method;
  final VoidCallback? onUseAnotherAccount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    final isGoogle = method == LoginMethod.google;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primary,
            child: Text(
              initial,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGoogle ? 'Você entra com o Google' : 'Continue como',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.slate500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onUseAnotherAccount,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 44),
            ),
            child: Text(
              'Trocar',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
