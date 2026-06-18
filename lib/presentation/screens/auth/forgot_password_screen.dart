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
import 'package:mobile/presentation/widgets/ui/senior_toast.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  var _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authControllerProvider.notifier).sendPasswordReset(
          email: _emailController.text,
        );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (state.hasError) {
      showSeniorToast(
        context,
        title: 'Não foi possível enviar',
        message: state.error.toString().replaceFirst('Exception: ', ''),
        variant: SeniorToastVariant.danger,
      );
      return;
    }

    setState(() => _emailSent = true);
    showSeniorToast(
      context,
      title: 'E-mail enviado',
      message: 'Verifique sua caixa de entrada para redefinir a senha.',
      variant: SeniorToastVariant.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authAction = ref.watch(authControllerProvider);
    final isLoading = authAction.isLoading;

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.slate900,
        elevation: 0,
        leading: Semantics(
          button: true,
          label: 'Voltar',
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadius),
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.vpn_key_outlined,
                      size: 36,
                      color: AppColors.warning,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Esqueci minha senha',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _emailSent
                      ? 'Enviamos um link para ${_emailController.text.trim()}. Verifique sua caixa de entrada.'
                      : 'Sem problemas! Informe seu e-mail e enviaremos um link para redefinir sua senha.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                if (!_emailSent) ...[
                  SeniorInput(
                    controller: _emailController,
                    label: 'E-mail',
                    hint: 'seu@email.com',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.email_outlined,
                    autocorrect: false,
                    onSubmitted: (_) => _submit(),
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
                  const SizedBox(height: AppSpacing.lg),
                  SeniorButton(
                    label: 'Enviar link de redefinição',
                    icon: Icons.mail_outline,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                SeniorButton(
                  label: 'Voltar para entrar',
                  variant: SeniorButtonVariant.secondary,
                  icon: Icons.arrow_back,
                  onPressed: isLoading ? null : () => context.go(AppRoutes.login),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
