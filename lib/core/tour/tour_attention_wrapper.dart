import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_spacing.dart';
import 'package:mobile/core/tour/tour_gate.dart';
import 'package:mobile/core/tour/tour_id.dart';

/// Wraps [child] with a 5-second attention animation (scale pulse) and,
/// conditionally, a transient tooltip pop-up below the widget.
///
/// **Animation** — always runs, regardless of mode or visit count.
///
/// **Tooltip "Conheça as funções"** — shown only when:
/// - [tourId] is provided, AND
/// - the user is in Modo Básico, AND
/// - this is the first time visiting the screen
///   ([TourGate.shouldOfferFirstUse]).
///
/// If [tourId] is `null`, the tooltip is always shown (no gate check).
class TourAttentionWrapper extends ConsumerStatefulWidget {
  const TourAttentionWrapper({
    required this.child,
    this.tourId,
    this.tooltipText = 'Conheça as funções',
    super.key,
  });

  final Widget child;

  /// When provided, the tooltip is shown only on the first visit in Modo Básico.
  /// When null, the tooltip is always shown.
  final TourId? tourId;

  /// Text shown in the pop-up below the widget.
  final String tooltipText;

  @override
  ConsumerState<TourAttentionWrapper> createState() =>
      _TourAttentionWrapperState();
}

const _kTotalDuration = Duration(seconds: 5);
const _kPulseCycle = Duration(milliseconds: 600);

class _TourAttentionWrapperState extends ConsumerState<TourAttentionWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;
  OverlayEntry? _overlay;
  Timer? _stopTimer;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: _kPulseCycle);
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Animation always starts regardless of mode.
      _pulseCtrl.repeat(reverse: true);
      _stopTimer = Timer(_kTotalDuration, _stop);

      final id = widget.tourId;
      if (id != null) {
        // Gate check: tooltip only on first visit in Modo Básico.
        final gate = ref.read(tourGateProvider);
        final shouldShow = await gate.shouldOfferFirstUse(id);
        if (!mounted) return;
        if (shouldShow) {
          await gate.markOffered(id);
          if (mounted) _showTooltip();
        }
      } else {
        // No gate check: always show (no tour tracking configured).
        _showTooltip();
      }
    });
  }

  void _showTooltip() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;

    _overlay = OverlayEntry(
      builder: (ctx) {
        final screenWidth = MediaQuery.of(ctx).size.width;
        // Align tooltip's right edge with the button's right edge,
        // clamped so it never slides off-screen.
        final rightOffset = (screenWidth - pos.dx - size.width).clamp(
          AppSpacing.sm,
          screenWidth - 4,
        );
        return Positioned(
          top: pos.dy + size.height + 6,
          right: rightOffset,
          child: _TooltipPopup(text: widget.tooltipText),
        );
      },
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _stop() {
    if (!mounted) return;
    _pulseCtrl.stop();
    // Smoothly return icon to its original scale.
    _pulseCtrl.animateTo(0, duration: const Duration(milliseconds: 300));
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _removeOverlay();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _scaleAnim, child: widget.child);
  }
}

// ─────────────────────────────────────────────────────────────────── Tooltip ──

class _TooltipPopup extends StatefulWidget {
  const _TooltipPopup({required this.text});
  final String text;

  @override
  State<_TooltipPopup> createState() => _TooltipPopupState();
}

class _TooltipPopupState extends State<_TooltipPopup> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    // Fade in after the first frame so AnimatedOpacity captures the transition.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _opacity = 1.0);
    });
    // Start fade-out slightly before the wrapper removes the overlay (5 s),
    // so the exit animation completes gracefully.
    Future.delayed(const Duration(milliseconds: 4400), () {
      if (mounted) setState(() => _opacity = 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _opacity,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 170),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 4,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x29000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: AppColors.primaryLight),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.help_outline,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  widget.text,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    height: 1.2,
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
