import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Fábricas de máscaras de input partilhadas pelo Design System.
///
/// Cada chamada devolve uma **nova** instância de [MaskTextInputFormatter]
/// porque o formatter guarda estado interno (não deve ser partilhado entre
/// campos). O `#` representa um dígito `[0-9]`.
///
/// Vivem em `core/` (sem regra de negócio) para poderem ser reutilizadas por
/// qualquer feature.
abstract final class InputMasks {
  /// Telefone brasileiro com nono dígito: `(19) 9 9999-0034`.
  static MaskTextInputFormatter phone() => MaskTextInputFormatter(
        mask: '(##) # ####-####',
        filter: {'#': RegExp(r'[0-9]')},
      );

  /// CPF: `999.999.999-99`.
  static MaskTextInputFormatter cpf() => MaskTextInputFormatter(
        mask: '###.###.###-##',
        filter: {'#': RegExp(r'[0-9]')},
      );

  /// CEP: `99999-999`.
  static MaskTextInputFormatter cep() => MaskTextInputFormatter(
        mask: '#####-###',
        filter: {'#': RegExp(r'[0-9]')},
      );

  /// Data de nascimento: `99/99/9999`.
  static MaskTextInputFormatter birthDate() => MaskTextInputFormatter(
        mask: '##/##/####',
        filter: {'#': RegExp(r'[0-9]')},
      );
}
