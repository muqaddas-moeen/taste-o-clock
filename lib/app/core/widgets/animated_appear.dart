import 'package:flutter/material.dart';
import 'package:taste_o_clock/app/core/animations/app_animations.dart';

/// Smoothly animates when a conditional widget appears or disappears.
class AnimatedAppear extends StatelessWidget {
  const AnimatedAppear({
    super.key,
    required this.show,
    required this.child,
    this.slideOffset = const Offset(0, -0.08),
  });

  final bool show;
  final Widget child;
  final Offset slideOffset;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppAnimations.medium,
      switchInCurve: AppAnimations.easeOut,
      switchOutCurve: AppAnimations.easeInOut,
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: slideOffset,
          end: Offset.zero,
        ).animate(animation);

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: offsetAnimation,
            child: child,
          ),
        );
      },
      child: show
          ? KeyedSubtree(
              key: const ValueKey('visible'),
              child: child,
            )
          : const SizedBox.shrink(key: ValueKey('hidden')),
    );
  }
}
