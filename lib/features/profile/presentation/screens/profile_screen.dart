import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/tour/senior_showcase.dart';
import 'package:mobile/core/tour/tour_dialogs.dart';
import 'package:mobile/core/tour/tour_gate.dart';
import 'package:mobile/core/tour/tour_help_button.dart';
import 'package:mobile/core/tour/tour_host.dart';
import 'package:mobile/core/tour/tour_id.dart';
import 'package:mobile/core/tour/tour_signal_provider.dart';
import 'package:mobile/core/utils/input_masks.dart';
import 'package:mobile/core/widgets/senior_button.dart';
import 'package:mobile/core/widgets/senior_input.dart';
import 'package:mobile/core/widgets/senior_screen_scaffold.dart';
import 'package:mobile/core/widgets/senior_toast.dart';
import 'package:mobile/features/accessibility/domain/entities/user_preferences.dart';
import 'package:mobile/features/accessibility/presentation/providers/preferences_provider.dart';
import 'package:mobile/features/profile/domain/entities/address.dart';
import 'package:mobile/features/profile/domain/entities/user_profile.dart';
import 'package:mobile/features/profile/presentation/providers/profile_provider.dart';

/// Tela de Perfil: exibe a foto/nome/email/telefone e permite editar os dados
/// pessoais e o endereço. A foto é enviada para o Firebase Storage.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TourHost<ProfileScreen> {
  static const String _scope = 'profile';

  final _formKey = GlobalKey<FormState>();

  // Alvos do tutorial guiado (na ordem de exibição).
  final _photoShowcaseKey = GlobalKey();
  final _infoShowcaseKey = GlobalKey();
  final _saveShowcaseKey = GlobalKey();

  // Controladores dos campos editáveis.
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cpfController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  String? _photoUrl;
  bool _populated = false;
  bool _uploadingPhoto = false;

  @override
  String get tourScope => _scope;

  @override
  TourId get tourId => TourId.profile;

  @override
  List<GlobalKey> get tourKeys =>
      [_photoShowcaseKey, _infoShowcaseKey, _saveShowcaseKey];

  @override
  void initState() {
    super.initState();
    // Popula o formulário assim que o perfil estiver disponível e, depois,
    // oferece o tutorial na 1.ª utilização (apenas Modo Básico).
    ref.listenManual<AsyncValue<UserProfile>>(profileProvider, (_, next) {
      final profile = next.asData?.value;
      if (profile != null) _populate(profile);
    }, fireImmediately: true);

    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeOfferFirstUse());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _phoneController.dispose();
    _cpfController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _zipCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _populate(UserProfile profile) {
    if (_populated) return;
    _populated = true;
    _nameController.text = profile.name;
    _birthDateController.text = profile.birthDate ?? '';
    _phoneController.text = profile.phone ?? '';
    _cpfController.text = profile.cpf ?? '';
    _neighborhoodController.text = profile.address.neighborhood;
    _streetController.text = profile.address.street;
    _numberController.text = profile.address.number;
    _zipCodeController.text = profile.address.zipCode;
    _cityController.text = profile.address.city;
    _stateController.text = profile.address.state;
    _countryController.text = profile.address.country;
    setState(() => _photoUrl = profile.photoUrl);
  }

  /// Na primeira utilização (apenas em Modo Básico), pergunta se pode mostrar
  /// como funciona o perfil. A decisão de "quando" é toda do [TourGate].
  Future<void> _maybeOfferFirstUse() async {
    if (!mounted) return;
    if (ref.read(tourSessionProvider)) return;

    final gate = ref.read(tourGateProvider);
    if (!await gate.shouldOfferFirstUse(TourId.profile)) return;
    if (!mounted) return;

    ref.read(tourSessionProvider.notifier).markAutoOffered();
    await gate.markOffered(TourId.profile);
    if (!mounted) return;

    final accepted = await showTourInviteDialog(
      context,
      title: 'Vamos fazer juntos?',
      message: 'Posso mostrar rapidamente como ver e mudar seus dados?',
      acceptLabel: 'Sim',
      declineLabel: 'Agora não',
    );
    if (accepted && mounted) startTour();
  }

  bool get _isBasicMode =>
      ref.watch(preferencesProvider).asData?.value.interfaceMode ==
      InterfaceMode.basic;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final profile = profileAsync.asData?.value;
    final saving = ref.watch(profileControllerProvider).isLoading;

    return SeniorScreenScaffold(
      title: 'Perfil',
      subtitle: 'Veja e atualize seus dados',
      trailing: TourHelpButton(onPressed: startTour),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  // ----------------------------------------- Bloco: Perfil
                  SeniorShowcase(
                    showcaseKey: _photoShowcaseKey,
                    scope: _scope,
                    title: 'A sua foto',
                    description:
                        'Toque em "Alterar foto" para escolher uma foto da galeria ou tirar uma nova.',
                    child: _ProfileHeaderCard(
                      profile: profile,
                      photoUrl: _photoUrl,
                      uploading: _uploadingPhoto,
                      onChangePhoto: _showPhotoSourceSheet,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // -------------------------- Bloco: Informações Pessoais
                  SeniorShowcase(
                    showcaseKey: _infoShowcaseKey,
                    scope: _scope,
                    title: 'Os seus dados',
                    description:
                        'Aqui você pode escrever seu nome, telefone e outros dados. O e-mail não muda.',
                    child: _SectionCard(
                      title: 'Informações Pessoais',
                      icon: Icons.person_outline,
                      children: [
                        SeniorInput(
                          controller: _nameController,
                          label: 'Nome Completo',
                          hint: 'Ex.: Maria Silva',
                          prefixIcon: Icons.badge_outlined,
                          maxLength: 30,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SeniorInput(
                          label: 'E-mail',
                          hint: profile.email,
                          controller:
                              TextEditingController(text: profile.email),
                          prefixIcon: Icons.email_outlined,
                          readOnly: true,
                          enabled: false,
                          helperText: 'O e-mail não pode ser alterado.',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SeniorInput(
                          controller: _birthDateController,
                          label: 'Data de Nascimento',
                          hint: 'DD/MM/AAAA',
                          prefixIcon: Icons.cake_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [InputMasks.birthDate()],
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SeniorInput(
                          controller: _phoneController,
                          label: 'Telefone',
                          hint: '(19) 9 9999-9999',
                          prefixIcon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [InputMasks.phone()],
                          textInputAction: TextInputAction.next,
                        ),
                        // CPF é opcional → oculto em Modo Básico para reduzir
                        // a carga cognitiva (regra de simplificação do projeto).
                        if (!_isBasicMode) ...[
                          const SizedBox(height: AppSpacing.sm),
                          SeniorInput(
                            controller: _cpfController,
                            label: 'CPF (opcional)',
                            hint: '000.000.000-00',
                            prefixIcon: Icons.assignment_ind_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [InputMasks.cpf()],
                            textInputAction: TextInputAction.next,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // --------------------------------------- Bloco: Endereço
                  _SectionCard(
                    title: 'Endereço',
                    icon: Icons.home_outlined,
                    children: [
                      SeniorInput(
                        controller: _neighborhoodController,
                        label: 'Bairro',
                        prefixIcon: Icons.location_city_outlined,
                        maxLength: 30,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: SeniorInput(
                              controller: _streetController,
                              label: 'Rua',
                              maxLength: 50,
                              compactLabel: true,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: SeniorInput(
                              controller: _numberController,
                              label: 'Número',
                              compactLabel: true,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SeniorInput(
                        controller: _zipCodeController,
                        label: 'CEP',
                        hint: '99999-999',
                        prefixIcon: Icons.markunread_mailbox_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [InputMasks.cep()],
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: SeniorInput(
                              controller: _cityController,
                              label: 'Cidade',
                              maxLength: 30,
                              compactLabel: true,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: SeniorInput(
                              controller: _stateController,
                              label: 'Estado',
                              maxLength: 30,
                              compactLabel: true,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SeniorInput(
                        controller: _countryController,
                        label: 'País',
                        prefixIcon: Icons.public_outlined,
                        maxLength: 30,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ----------------------------------------- Botão Guardar
                  SeniorShowcase(
                    showcaseKey: _saveShowcaseKey,
                    scope: _scope,
                    title: 'Salvar alterações',
                    description:
                        'Quando terminar, toque aqui para salvar seus dados.',
                    child: SeniorButton(
                      label: 'Salvar alterações',
                      icon: Icons.check,
                      isLoading: saving,
                      onPressed: saving ? null : () => _save(profile),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  // ------------------------------------------------------------------ Foto

  void _showPhotoSourceSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Alterar foto de perfil',
                style: Theme.of(sheetContext).textTheme.headlineMedium,
              ),
            ),
            _PhotoSourceTile(
              icon: Icons.photo_library_outlined,
              label: 'Escolher da galeria',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAndUpload(ImageSource.gallery);
              },
            ),
            _PhotoSourceTile(
              icon: Icons.photo_camera_outlined,
              label: 'Tirar uma foto',
              onTap: () {
                Navigator.of(sheetContext).pop();
                _pickAndUpload(ImageSource.camera);
              },
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    final base = ref.read(profileProvider).asData?.value;
    if (base == null || base.id.isEmpty) return;

    setState(() => _uploadingPhoto = true);
    final bytes = await file.readAsBytes();
    final url =
        await ref.read(profileControllerProvider.notifier).uploadPhoto(
              base.id,
              bytes,
            );
    if (!mounted) return;

    if (url == null) {
      setState(() => _uploadingPhoto = false);
      showSeniorToast(
        context,
        title: 'Não foi possível enviar a foto',
        message: 'Tente novamente daqui a pouco.',
        variant: SeniorToastVariant.danger,
      );
      return;
    }

    // Persiste de imediato o photoUrl (merge — não toca nos dados do formulário
    // ainda por guardar).
    await ref
        .read(profileControllerProvider.notifier)
        .save(base.copyWith(photoUrl: url));
    if (!mounted) return;

    setState(() {
      _photoUrl = url;
      _uploadingPhoto = false;
    });
    showSeniorToast(
      context,
      title: 'Foto atualizada',
      message: 'A sua nova foto de perfil já está guardada.',
      variant: SeniorToastVariant.success,
    );
  }

  // ---------------------------------------------------------------- Guardar

  Future<void> _save(UserProfile base) async {
    FocusScope.of(context).unfocus();
    HapticFeedback.mediumImpact();

    if (_nameController.text.trim().isEmpty) {
      showSeniorToast(
        context,
        title: 'Falta o nome',
        message: 'Escreva seu nome completo antes de salvar.',
        variant: SeniorToastVariant.warning,
      );
      return;
    }

    final updated = base.copyWith(
      name: _nameController.text.trim(),
      phone: _phoneController.text,
      birthDate: _birthDateController.text,
      cpf: _cpfController.text,
      photoUrl: _photoUrl,
      address: Address(
        neighborhood: _neighborhoodController.text.trim(),
        street: _streetController.text.trim(),
        number: _numberController.text.trim(),
        zipCode: _zipCodeController.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
      ),
    );

    await ref.read(profileControllerProvider.notifier).save(updated);
    if (!mounted) return;

    final state = ref.read(profileControllerProvider);
    if (state is AsyncError) {
      showSeniorToast(
        context,
        title: 'Erro ao salvar',
        message: 'Não foi possível salvar seus dados. Tente novamente.',
        variant: SeniorToastVariant.danger,
      );
    } else {
      showSeniorToast(
        context,
        title: 'Dados guardados',
        message: 'As suas informações foram atualizadas.',
        variant: SeniorToastVariant.success,
      );
    }
  }
}

// ------------------------------------------------------------------ Widgets

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.profile,
    required this.photoUrl,
    required this.uploading,
    required this.onChangePhoto,
  });

  final UserProfile profile;
  final String? photoUrl;
  final bool uploading;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  image: hasPhoto
                      ? DecorationImage(
                          image: NetworkImage(photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: uploading
                    ? const CircularProgressIndicator()
                    : (hasPhoto
                        ? null
                        : Text(
                            profile.initials,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            profile.name.isNotEmpty ? profile.name : 'Usuário',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            profile.email,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.slate500,
            ),
          ),
          if (profile.hasPhone) ...[
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone, size: 16, color: AppColors.slate500),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  profile.phone!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SeniorButton(
            label: 'Alterar foto',
            icon: Icons.camera_alt_outlined,
            variant: SeniorButtonVariant.secondary,
            onPressed: uploading ? null : onChangePhoto,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _PhotoSourceTile extends StatelessWidget {
  const _PhotoSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
