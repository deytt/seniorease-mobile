import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/widgets/senior_modal.dart';
import 'package:mobile/features/auth/presentation/providers/auth_provider.dart';

/// Header gradiente com saudação dinâmica, nome do utilizador e botão SOS.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia ☀️';
    if (hour < 18) return 'Boa tarde 🌤️';
    return 'Boa noite 🌙';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(authStateProvider).asData?.value;
    final firstName = user?.name.split(' ').firstOrNull ?? 'Utilizador';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Expanded garante que textos longos não colidam com o SOS button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFBEDBFF),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$firstName!',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SosButton(),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _NextActivityCard(),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ SOS Button

class _SosButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Botão de emergência SOS',
      child: GestureDetector(
        onTap: () => showSeniorConfirmDialog(
          context: context,
          title: 'Emergência',
          message:
              'Ligue para o nosso suporte de emergência:\n\n📞 1-800-SENIOR\n\nEstamos disponíveis 24 horas.',
          confirmLabel: 'Entendido',
          cancelLabel: 'Fechar',
          isDestructive: false,
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.danger,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            // "SOS" é sempre 3 chars — não precisa de escalar com o tema
            child: Text(
              'SOS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------ Next Activity Card

class _NextActivityCard extends StatelessWidget {
  const _NextActivityCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRÓXIMA ATIVIDADE',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFBEDBFF),
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nenhuma atividade agendada',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 12,
                      color: Color(0xFFDBEAFE),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Cria uma tarefa para começar',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Iniciar →',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
