import 'package:cloud_firestore/cloud_firestore.dart';

enum FontSizeScale {
  small,
  medium,
  large,
  extraLarge;

  /// Factor de escala aplicado ao TextTheme
  double get scale => switch (this) {
        FontSizeScale.small => 0.875,
        FontSizeScale.medium => 1.0,
        FontSizeScale.large => 1.2,
        FontSizeScale.extraLarge => 1.5,
      };

  /// Percentagem exibida na UI (ex: "120%")
  String get label => switch (this) {
        FontSizeScale.small => '87%',
        FontSizeScale.medium => '100%',
        FontSizeScale.large => '120%',
        FontSizeScale.extraLarge => '150%',
      };

  static FontSizeScale fromString(String value) => switch (value) {
        'small' => FontSizeScale.small,
        'large' => FontSizeScale.large,
        'extra_large' => FontSizeScale.extraLarge,
        _ => FontSizeScale.medium,
      };

  String toFirestore() => switch (this) {
        FontSizeScale.small => 'small',
        FontSizeScale.medium => 'medium',
        FontSizeScale.large => 'large',
        FontSizeScale.extraLarge => 'extra_large',
      };
}

enum ContrastMode {
  defaultMode,
  high,
  maximum;

  static ContrastMode fromString(String value) => switch (value) {
        'high' => ContrastMode.high,
        'maximum' => ContrastMode.maximum,
        _ => ContrastMode.defaultMode,
      };

  String toFirestore() => switch (this) {
        ContrastMode.defaultMode => 'default',
        ContrastMode.high => 'high',
        ContrastMode.maximum => 'maximum',
      };
}

enum SpacingMode {
  compact,
  comfortable,
  spacious;

  static SpacingMode fromString(String value) => switch (value) {
        'compact' => SpacingMode.compact,
        'spacious' => SpacingMode.spacious,
        _ => SpacingMode.comfortable,
      };

  String toFirestore() => name;
}

enum InterfaceMode {
  basic,
  advanced;

  static InterfaceMode fromString(String value) =>
      value == 'advanced' ? InterfaceMode.advanced : InterfaceMode.basic;

  String toFirestore() => name;
}

class UserPreferences {
  const UserPreferences({
    required this.userId,
    required this.fontSize,
    required this.darkMode,
    required this.contrast,
    required this.spacing,
    required this.interfaceMode,
    required this.audioFeedbackEnabled,
    required this.largeTouchTargets,
    required this.remindersEnabled,
    required this.updatedAt,
    this.notificationTime,
  });

  final String userId;

  /// Escala tipográfica (small / medium / large / extraLarge)
  final FontSizeScale fontSize;

  /// Tema escuro
  final bool darkMode;

  /// Modo de contraste; 'maximum' é derivado automaticamente quando
  /// darkMode == true && contrast == high
  final ContrastMode contrast;

  /// Modo de espaçamento (aplicado globalmente pelo tema)
  final SpacingMode spacing;

  /// Modo básico ou avançado da interface
  final InterfaceMode interfaceMode;

  /// Feedback visual + háptico + áudio nos botões e acções
  final bool audioFeedbackEnabled;

  /// Touch targets de 64×64px em vez de 48×48px
  final bool largeTouchTargets;

  final bool remindersEnabled;
  final String? notificationTime;
  final DateTime updatedAt;

  /// Preferências padrão (usadas offline ou antes do Firestore responder)
  factory UserPreferences.defaults({String userId = ''}) => UserPreferences(
        userId: userId,
        fontSize: FontSizeScale.medium,
        darkMode: false,
        contrast: ContrastMode.defaultMode,
        spacing: SpacingMode.comfortable,
        interfaceMode: InterfaceMode.advanced,
        audioFeedbackEnabled: false,
        largeTouchTargets: false,
        remindersEnabled: true,
        updatedAt: DateTime.now(),
      );

  UserPreferences copyWith({
    String? userId,
    FontSizeScale? fontSize,
    bool? darkMode,
    ContrastMode? contrast,
    SpacingMode? spacing,
    InterfaceMode? interfaceMode,
    bool? audioFeedbackEnabled,
    bool? largeTouchTargets,
    bool? remindersEnabled,
    String? notificationTime,
    DateTime? updatedAt,
  }) =>
      UserPreferences(
        userId: userId ?? this.userId,
        fontSize: fontSize ?? this.fontSize,
        darkMode: darkMode ?? this.darkMode,
        contrast: contrast ?? this.contrast,
        spacing: spacing ?? this.spacing,
        interfaceMode: interfaceMode ?? this.interfaceMode,
        audioFeedbackEnabled: audioFeedbackEnabled ?? this.audioFeedbackEnabled,
        largeTouchTargets: largeTouchTargets ?? this.largeTouchTargets,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        notificationTime: notificationTime ?? this.notificationTime,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'fontSize': fontSize.toFirestore(),
        'darkMode': darkMode,
        'contrast': contrast.toFirestore(),
        'spacing': spacing.toFirestore(),
        'interfaceMode': interfaceMode.toFirestore(),
        'audioFeedbackEnabled': audioFeedbackEnabled,
        'largeTouchTargets': largeTouchTargets,
        'remindersEnabled': remindersEnabled,
        'notificationTime': notificationTime,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory UserPreferences.fromMap(String userId, Map<String, dynamic> map) =>
      UserPreferences(
        userId: userId,
        fontSize: FontSizeScale.fromString(map['fontSize'] as String? ?? ''),
        darkMode: map['darkMode'] as bool? ?? false,
        contrast:
            ContrastMode.fromString(map['contrast'] as String? ?? ''),
        spacing: SpacingMode.fromString(map['spacing'] as String? ?? ''),
        interfaceMode:
            InterfaceMode.fromString(map['interfaceMode'] as String? ?? ''),
        audioFeedbackEnabled:
            map['audioFeedbackEnabled'] as bool? ?? false,
        largeTouchTargets: map['largeTouchTargets'] as bool? ?? false,
        remindersEnabled: map['remindersEnabled'] as bool? ?? true,
        notificationTime: map['notificationTime'] as String?,
        updatedAt:
            (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
}
