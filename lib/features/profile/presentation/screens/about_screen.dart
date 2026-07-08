import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/feedback/senior_feedback.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:url_launcher/url_launcher.dart';

/// Tela "Sobre": identidade do app, versão e ligação para a aplicação web.
class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen>
    with TourHost<AboutScreen> {
  static const String _scope = 'about';

  static const String _webUrl = 'https://seniorease-web.vercel.app/';
  static const String _appVersion = 'Versão 1.0.0';

  // Alvos do tutorial guiado (na ordem de exibição).
  final _descShowcaseKey = GlobalKey();
  final _webShowcaseKey = GlobalKey();

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.about;

  @override
  List<GlobalKey> get tourKeys => [_descShowcaseKey, _webShowcaseKey];

  Future<void> _openWeb() async {
    await SeniorFeedback.light(ref);
    final uri = Uri.parse(_webUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      showSeniorToast(
        context,
        title: 'Não foi possível abrir',
        message: 'Tente novamente mais tarde.',
        variant: SeniorToastVariant.danger,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SeniorScreenScaffold(
      title: 'Sobre',
      backIcon: Icons.chevron_left,
      onBack: () => Navigator.of(context).pop(),
      trailing: TourHelpButton(onPressed: startTour, tourId: tourId),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: AppSpacing.lg),
            // Identidade do app
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'SeniorEase',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _appVersion,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.slate500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Descrição
            SeniorShowcase(
              showcaseKey: _descShowcaseKey,
              scope: _scope,
              title: 'Sobre a aplicação',
              description:
                  'Aqui vê o que a aplicação faz e qual a versão instalada.',
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'O SeniorEase ajuda no dia a dia: tarefas e lembretes simples, '
                  'com ajuda passo a passo. Feito a pensar em si, com letras '
                  'maiores e botões fáceis de tocar.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Aplicação web (clicável)
            SeniorShowcase(
              showcaseKey: _webShowcaseKey,
              scope: _scope,
              title: 'Aplicação web',
              description:
                  'Toque aqui para abrir o SeniorEase no computador, pelo navegador.',
              child: _WebAppCard(url: _webUrl, onTap: _openWeb),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Feito com carinho para si 💙',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.slate500,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _WebAppCard extends StatelessWidget {
  const _WebAppCard({required this.url, required this.onTap});

  final String url;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Abrir a aplicação web no navegador',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.public,
                      color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aplicação web',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Use também no computador',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.primaryDark.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.open_in_new,
                    color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
