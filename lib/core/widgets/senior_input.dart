import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/theme/app_theme.dart';

class SeniorInput extends StatefulWidget {
  const SeniorInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.enabled = true,
    this.autocorrect = true,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.semanticLabel,
    this.compactLabel = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool autocorrect;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final String? semanticLabel;
  final bool compactLabel;

  @override
  State<SeniorInput> createState() => _SeniorInputState();
}

class _SeniorInputState extends State<SeniorInput> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Semantics(
      textField: true,
      label: widget.semanticLabel ?? widget.label,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: widget.compactLabel
                  ? Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      )
                  : Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.slate900,
                      ),
            ),
            const SizedBox(height: 6),
          ],
          SizedBox(
            height: AppTheme.inputHeight,
            child: TextFormField(
              controller: widget.controller,
              enabled: widget.enabled,
              obscureText: _obscure,
              autocorrect: widget.autocorrect,
              keyboardType: widget.keyboardType,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onFieldSubmitted: widget.onSubmitted,
              validator: widget.validator,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.slate900,
                  ),
              decoration: InputDecoration(
                hintText: widget.hint,
                errorText: hasError ? widget.errorText : null,
                prefixIcon: widget.prefixIcon != null
                    ? Icon(
                        widget.prefixIcon,
                        color: hasError ? AppColors.danger : AppColors.slate400,
                        size: 22,
                      )
                    : null,
                suffixIcon: widget.obscureText
                    ? Semantics(
                        button: true,
                        label: _obscure ? 'Mostrar senha' : 'Ocultar senha',
                        child: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.slate400,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      )
                    : null,
              ),
            ),
          ),
          if (widget.helperText != null && !hasError) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.helperText!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.slate500,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}
