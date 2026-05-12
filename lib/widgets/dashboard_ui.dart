import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class DashboardCard extends StatelessWidget {
  const DashboardCard({
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.accent,
    this.onTap,
    this.clipBehavior = Clip.antiAlias,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final Color? accent;
  final VoidCallback? onTap;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final borderColor = accent?.withValues(alpha: 0.32) ?? AppTheme.cardBorder;
    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      margin: margin,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: (accent ?? Colors.black).withValues(alpha: accent == null ? 0.18 : 0.12),
            blurRadius: accent == null ? 18 : 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: content,
      ),
    );
  }
}

class DashboardIconBox extends StatelessWidget {
  const DashboardIconBox({
    required this.icon,
    this.color = AppTheme.accent,
    this.size = 41,
    this.radius = 2,
    super.key,
  });

  final IconData icon;
  final Color color;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class StaggeredReveal extends StatefulWidget {
  const StaggeredReveal({
    required this.child,
    this.index = 0,
    this.baseDelay = const Duration(milliseconds: 55),
    this.duration = const Duration(milliseconds: 420),
    super.key,
  });

  final Widget child;
  final int index;
  final Duration baseDelay;
  final Duration duration;

  @override
  State<StaggeredReveal> createState() => _StaggeredRevealState();
}

class _StaggeredRevealState extends State<StaggeredReveal> {
  bool _visible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.baseDelay * widget.index, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void didUpdateWidget(covariant StaggeredReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child.key != widget.child.key) {
      _visible = false;
      _timer?.cancel();
      _timer = Timer(widget.baseDelay * widget.index, () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: Curves.easeOutCubic,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    required this.value,
    this.color = AppTheme.accent,
    this.backgroundColor = Colors.white10,
    super.key,
  });

  final double value;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: animated,
            minHeight: 6,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        );
      },
    );
  }
}

class AnimatedMetricText extends StatelessWidget {
  const AnimatedMetricText({
    required this.value,
    required this.formatter,
    required this.style,
    super.key,
  });

  final double value;
  final String Function(double value) formatter;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) {
        return Text(formatter(animated), style: style);
      },
    );
  }
}

class SoftPulse extends StatefulWidget {
  const SoftPulse({
    required this.child,
    this.enabled = true,
    this.minScale = 0.94,
    this.maxScale = 1,
    super.key,
  });

  final Widget child;
  final bool enabled;
  final double minScale;
  final double maxScale;

  @override
  State<SoftPulse> createState() => _SoftPulseState();
}

class _SoftPulseState extends State<SoftPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant SoftPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return ScaleTransition(
      scale: Tween(begin: widget.minScale, end: widget.maxScale).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}
