import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/router.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_logo.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:mobile/features/auth/presentation/providers/biometric_provider.dart';

class BiometricLockScreen extends ConsumerStatefulWidget {
  const BiometricLockScreen({super.key});

  @override
  ConsumerState<BiometricLockScreen> createState() =>
      _BiometricLockScreenState();
}

class _BiometricLockScreenState extends ConsumerState<BiometricLockScreen> {
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    // Dispara o prompt biométrico logo após o primeiro frame para que a tela
    // esteja visível ao utilizador antes de o sistema mostrar o diálogo nativo.
    SchedulerBinding.instance.addPostFrameCallback((_) => _tryBiometric());
  }

  Future<void> _tryBiometric() async {
    if (!mounted || _isAuthenticating) return;
    setState(() => _isAuthenticating = true);

    try {
      final controller = ref.read(biometricControllerProvider.notifier);
      final success = await controller.authenticateForLogin();

      if (!mounted) return;

      if (success) {
        ref.read(biometricLockedProvider.notifier).unlock();
        // Navegação explícita como garantia; o router redirect também captura.
        if (mounted) context.go(AppRoutes.home);
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  Future<void> _usePassword() async {
    await ref.read(authControllerProvider.notifier).signOut();
    if (!mounted) return;
    // Reseta o lock para que na próxima abertura autenticada o lock volte a
    // aparecer (apenas se o utilizador reativar biometria).
    ref.read(biometricLockedProvider.notifier).reset();
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primaryLight,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.xxl,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo
                const SeniorLogo(size: 96),
                const SizedBox(height: AppSpacing.xl),

                // Ícone biométrico
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: _isAuthenticating
                      ? const Padding(
                          padding: EdgeInsets.all(28),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.fingerprint,
                          size: 56,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Título
                Text(
                  'Bem-vindo de volta',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: AppColors.slate900,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),

                Text(
                  _isAuthenticating
                      ? 'Aguarde…'
                      : 'Toque para entrar com biometria',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.slate500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Botão de tentar novamente (visível após cancelamento)
                if (!_isAuthenticating)
                  SeniorButton(
                    label: 'Tentar novamente',
                    onPressed: _tryBiometric,
                  ),

                const Spacer(),

                // Botão secundário — usar senha
                TextButton(
                  onPressed: _isAuthenticating ? null : _usePassword,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(44, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  child: Text(
                    'Usar senha',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
