import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

String formatNPR(num amount) {
  final s = amount.round().toString();
  if (s.length <= 3) return 'NPR $s';
  final last3 = s.substring(s.length - 3);
  final rest = s.substring(0, s.length - 3);
  final groups = <String>[];
  for (var i = rest.length; i > 0; i -= 2) {
    groups.insert(0, rest.substring(math.max(0, i - 2), i));
  }
  return 'NPR ${groups.join(',')},$last3';
}

String formatDate(DateTime d) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

const Map<String, String> purposeIcons = {
  'Agriculture': '🌾',
  'Education': '📚',
  'Business': '🏪',
  'Medical': '🏥',
  'Home': '🏠',
  'Vehicle': '🚗',
  'Electronics': '💻',
};

class DhakaPattern extends StatelessWidget {
  const DhakaPattern({super.key, this.opacity = 0.12});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _DhakaPainter(opacity),
        size: Size.infinite,
      ),
    );
  }
}

class _DhakaPainter extends CustomPainter {
  _DhakaPainter(this.opacity);

  final double opacity;

  Color get base => AppColors.teal.withAlpha((opacity * 255).round());

  Color alphaOf(double f) =>
      AppColors.teal.withAlpha((opacity * f * 255).clamp(0, 255).round());

  @override
  void paint(Canvas canvas, Size size) {
    const cell = 40.0;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = alphaOf(2.5);
    final fill = Paint()..color = base;
    final dot = Paint()..color = alphaOf(3);
    final smallDot = Paint()..color = alphaOf(2);
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = alphaOf(2);

    final cols = (size.width / cell).ceil();
    final rows = (size.height / cell).ceil();

    for (var i = 0; i < cols; i++) {
      for (var j = 0; j < rows; j++) {
        final ox = i * cell;
        final oy = j * cell;
        final c = Offset(ox + 20, oy + 20);

        canvas.drawPath(
          Path()
            ..moveTo(ox + 20, oy + 4)
            ..lineTo(ox + 36, oy + 20)
            ..lineTo(ox + 20, oy + 36)
            ..lineTo(ox + 4, oy + 20)
            ..close(),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(ox + 20, oy + 10)
            ..lineTo(ox + 30, oy + 20)
            ..lineTo(ox + 20, oy + 30)
            ..lineTo(ox + 10, oy + 20)
            ..close(),
          fill,
        );
        canvas.drawCircle(c, 2.5, dot);
        canvas.drawCircle(Offset(ox, oy), 1.5, smallDot);
        canvas.drawCircle(Offset(ox + cell, oy), 1.5, smallDot);
        canvas.drawCircle(Offset(ox, oy + cell), 1.5, smallDot);
        canvas.drawCircle(Offset(ox + cell, oy + cell), 1.5, smallDot);
        canvas.drawLine(Offset(ox, oy + 20), Offset(ox + 4, oy + 20), line);
        canvas.drawLine(
            Offset(ox + 36, oy + 20), Offset(ox + cell, oy + 20), line);
        canvas.drawLine(Offset(ox + 20, oy), Offset(ox + 20, oy + 4), line);
        canvas.drawLine(
            Offset(ox + 20, oy + 36), Offset(ox + 20, oy + cell), line);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DhakaPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}

class SystemChromeStyle extends StatelessWidget {
  const SystemChromeStyle({super.key, required this.light, required this.child});

  final bool light;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: light ? Brightness.dark : Brightness.light,
        statusBarBrightness: light ? Brightness.light : Brightness.dark,
      ),
      child: child,
    );
  }
}

class UAppBar extends StatelessWidget {
  const UAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.back = false,
    this.onBack,
    this.actions,
    this.light = false,
  });

  final String title;
  final String? subtitle;
  final bool back;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final bg = light ? AppColors.white : AppColors.navy;
    final fg = light ? AppColors.navy : AppColors.white;

    return SystemChromeStyle(
      light: light,
      child: Container(
        color: bg,
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: Container(
          height: 56,
          padding: const EdgeInsets.only(left: 4, right: 8),
          decoration: BoxDecoration(
            border: light
                ? const Border(
                    bottom: BorderSide(color: AppColors.border, width: 1))
                : null,
          ),
          child: Row(
            children: [
              if (back)
                SizedBox(
                  width: 48,
                  height: 48,
                  child: BackArrow(color: fg, onTap: onBack),
                )
              else
                const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: kPoppins,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: fg,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontFamily: kInter,
                            fontSize: 12,
                            color: light
                                ? AppColors.secondary
                                : AppColors.alpha(Colors.white, 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (actions != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!,
                )
              else if (!back)
                const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class BackArrow extends StatelessWidget {
  const BackArrow({super.key, this.color = Colors.white, this.onTap, this.size = 24});

  final Color color;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap ?? () => Navigator.maybePop(context),
      radius: 24,
      child: SizedBox(
        width: 48,
        height: 48,
        child: CustomPaint(
          painter: _ArrowPainter(color),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path()
      ..moveTo(cx + 7, cy)
      ..lineTo(cx - 7, cy)
      ..moveTo(cx - 1, cy - 6)
      ..lineTo(cx - 7, cy)
      ..lineTo(cx - 1, cy + 6);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}

class IconBtn extends StatelessWidget {
  const IconBtn({
    super.key,
    required this.child,
    this.onTap,
    this.color = Colors.white,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(color: color),
            child: child,
          ),
        ),
      ),
    );
  }
}

class BottomNavItem {
  const BottomNavItem({required this.icon, required this.label, this.active = false});

  final Widget icon;
  final String label;
  final bool active;
}

class BottomNav extends StatelessWidget {
  const BottomNav({super.key, required this.items, this.onTap});

  final List<BottomNavItem> items;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: InkWell(
                onTap: onTap == null ? null : () => onTap!(i),
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconTheme(
                        data: IconThemeData(
                          color: items[i].active
                              ? AppColors.teal
                              : AppColors.secondary,
                        ),
                        child: items[i].icon,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontFamily: kInter,
                          fontSize: 11,
                          fontWeight:
                              items[i].active ? FontWeight.w600 : FontWeight.w400,
                          color: items[i].active
                              ? AppColors.teal
                              : AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.color = AppColors.white,
    this.radius = 16,
    this.borderColor = AppColors.border,
    this.shadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color color;
  final double radius;
  final Color? borderColor;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: 1),
        boxShadow: shadow
            ? [
                BoxShadow(
                  color: AppColors.alpha(AppColors.navy, 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      padding: padding,
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }
}

enum RiskLevel { low, medium, high }

RiskLevel riskLevelFromString(String level) {
  switch (level) {
    case 'Low':
      return RiskLevel.low;
    case 'High':
      return RiskLevel.high;
    default:
      return RiskLevel.medium;
  }
}

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.level});

  final String level;

  @override
  Widget build(BuildContext context) {
    final (bg, color, icon) = switch (level) {
      'Low' => (AppColors.riskLowBg, AppColors.riskLow, '↓'),
      'High' => (AppColors.riskHighBg, AppColors.riskHigh, '↑'),
      _ => (AppColors.riskMedBg, AppColors.riskMed, '~'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$icon $level Risk',
        style: TextStyle(
          fontFamily: kInter,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class GradeBadge extends StatelessWidget {
  const GradeBadge({super.key, required this.grade});

  final String grade;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color color;
    switch (grade) {
      case 'A':
      case 'A+':
        bg = AppColors.riskLowBg;
        color = AppColors.riskLow;
      case 'B':
      case 'B+':
        bg = AppColors.blueBg;
        color = AppColors.blueFg;
      case 'C':
        bg = AppColors.riskMedBg;
        color = AppColors.riskMed;
      case 'D':
        bg = AppColors.riskHighBg;
        color = AppColors.riskHigh;
      default:
        bg = AppColors.surface;
        color = AppColors.secondary;
    }
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(
        grade,
        style: TextStyle(
          fontFamily: kPoppins,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

enum AppBtnVariant { primary, secondary, ghost, danger }

enum AppBtnSize { sm, md, lg }

class AppBtn extends StatelessWidget {
  const AppBtn({
    super.key,
    required this.child,
    this.variant = AppBtnVariant.primary,
    this.size = AppBtnSize.md,
    this.onPressed,
    this.disabled = false,
    this.loading = false,
    this.fullWidth = false,
    this.borderColor,
    this.textColor,
    this.backgroundColor,
  });

  final Widget child;
  final AppBtnVariant variant;
  final AppBtnSize size;
  final VoidCallback? onPressed;
  final bool disabled;
  final bool loading;
  final bool fullWidth;
  final Color? borderColor;
  final Color? textColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final (h, px, fs) = switch (size) {
      AppBtnSize.sm => (36.0, 16.0, 13.0),
      AppBtnSize.lg => (56.0, 32.0, 16.0),
      AppBtnSize.md => (48.0, 24.0, 14.0),
    };

    Color bg;
    Color fg;
    Border? border;
    switch (variant) {
      case AppBtnVariant.primary:
        bg = AppColors.teal;
        fg = Colors.white;
      case AppBtnVariant.secondary:
        bg = Colors.transparent;
        fg = AppColors.teal;
        border = Border.all(color: borderColor ?? AppColors.teal, width: 1.5);
      case AppBtnVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.navy;
      case AppBtnVariant.danger:
        bg = AppColors.danger;
        fg = Colors.white;
    }
    if (backgroundColor != null) bg = backgroundColor!;
    if (textColor != null) fg = textColor!;
    if (disabled) {
      bg = AppColors.border;
      fg = AppColors.secondary;
    }

    final label = DefaultTextStyle(
      style: AppText.button
          .copyWith(fontSize: fs, color: fg, fontWeight: FontWeight.w600),
      textAlign: TextAlign.center,
      child: child,
    );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(child: label),
      ],
    );

    final btn = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled || loading ? null : onPressed,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: h,
          padding: EdgeInsets.symmetric(horizontal: px),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: border,
          ),
          child: content,
        ),
      ),
    );

    if (fullWidth) return btn;
    return IntrinsicWidth(child: btn);
  }
}

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.active = false, this.onPressed});

  final String label;
  final bool active;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.tealLight : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: active ? AppColors.teal : AppColors.border,
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: kInter,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? AppColors.teal : AppColors.secondary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.max = 100,
    this.color = AppColors.teal,
    this.height = 6,
  });

  final double value;
  final double max;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final pct = (value / max).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(height),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: pct,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(height),
          ),
        ),
      ),
    );
  }
}

class AppInput extends StatefulWidget {
  const AppInput({
    super.key,
    this.label,
    this.placeholder,
    this.controller,
    this.value,
    this.onChanged,
    this.error,
    this.hint,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.textInputAction,
    this.onSubmitted,
  });

  final String? label;
  final String? placeholder;
  final TextEditingController? controller;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? error;
  final String? hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.value);

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(widget.label!, style: AppText.label),
          ),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? AppColors.riskHigh : AppColors.border,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              if (widget.prefix != null) ...[
                widget.prefix!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onChanged,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  readOnly: widget.readOnly,
                  onTap: widget.onTap,
                  textInputAction: widget.textInputAction,
                  onSubmitted: widget.onSubmitted,
                  style: AppText.body.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: widget.placeholder,
                    hintStyle: AppText.body.copyWith(
                      fontSize: 15,
                      color: AppColors.secondary.withAlpha(140),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (widget.suffix != null) ...[
                const SizedBox(width: 8),
                widget.suffix!,
              ],
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.error!,
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                color: AppColors.riskHigh,
              ),
            ),
          )
        else if (widget.hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(widget.hint!, style: AppText.caption.copyWith(fontSize: 12)),
          ),
      ],
    );
  }
}

class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + 2 * t, 0),
              end: Alignment(1 + 2 * t, 0),
              colors: const [
                Color(0xFFE8EDF2),
                Color(0xFFF5F8FA),
                Color(0xFFE8EDF2),
              ],
            ),
          ),
        );
      },
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Skeleton(width: 48, height: 48, radius: 12),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Skeleton(width: 160, height: 14),
                            SizedBox(height: 8),
                            Skeleton(width: 100, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Skeleton(height: 8, radius: 4),
                  const SizedBox(height: 8),
                  const Skeleton(width: 90, height: 12),
                ],
              ),
            ),
            if (i < 2) const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
    this.action,
  });

  final String icon;
  final String title;
  final String desc;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.h3.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(fontSize: 14, height: 1.6),
          ),
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration:
                const BoxDecoration(color: AppColors.riskHighBg, shape: BoxShape.circle),
            child: const Text('⚠️', style: TextStyle(fontSize: 28)),
          ),
          const SizedBox(height: 12),
          Text('Something went wrong', textAlign: TextAlign.center, style: AppText.h3),
          const SizedBox(height: 12),
          Text(
            "We couldn't load this. Please try again.",
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(fontSize: 14),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            AppBtn(
              variant: AppBtnVariant.secondary,
              size: AppBtnSize.sm,
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: AppText.h4.copyWith(fontSize: 16))),
          ?action,
        ],
      ),
    );
  }
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.margin = 16});

  final double margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(vertical: margin),
      color: AppColors.border,
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final style = _statusStyles[status] ??
        (bg: AppColors.surface, color: AppColors.secondary);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: style.bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyle(
          fontFamily: kInter,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: style.color,
        ),
      ),
    );
  }
}

const Map<String, ({Color bg, Color color})> _statusStyles = {
  'On track': (bg: AppColors.riskLowBg, color: AppColors.riskLow),
  'Late': (bg: AppColors.riskHighBg, color: AppColors.riskHigh),
  'Repaid': (bg: AppColors.blueBg, color: AppColors.blueFg),
  'Active': (bg: AppColors.tealLight, color: AppColors.teal),
  'Funded': (bg: AppColors.riskLowBg, color: AppColors.riskLow),
  'Pending': (bg: AppColors.riskMedBg, color: AppColors.riskMed),
  'Not started': (bg: AppColors.surface, color: AppColors.secondary),
  'In review': (bg: AppColors.riskMedBg, color: AppColors.riskMed),
  'Approved': (bg: AppColors.riskLowBg, color: AppColors.riskLow),
  'Needs changes': (bg: AppColors.riskHighBg, color: AppColors.riskHigh),
};

class OTPInput extends StatelessWidget {
  const OTPInput({super.key, this.value = ''});

  final String value;

  @override
  Widget build(BuildContext context) {
    const gap = 10.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth =
            ((constraints.maxWidth - gap * 5) / 6).clamp(0.0, 44.0);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < 6; i++) ...[
              if (i > 0) const SizedBox(width: gap),
              Container(
                width: boxWidth,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color:
                      i < value.length ? AppColors.tealLight : AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: i < value.length ? AppColors.teal : AppColors.border,
                    width: 2,
                  ),
                ),
                child: Text(
                  i < value.length ? value[i] : '',
                  style: const TextStyle(
                    fontFamily: kPoppins,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class LoanCard extends StatelessWidget {
  const LoanCard({
    super.key,
    required this.purpose,
    required this.borrower,
    required this.amount,
    required this.rate,
    required this.tenor,
    required this.risk,
    required this.funded,
    required this.total,
    this.onTap,
  });

  final String purpose;
  final String borrower;
  final num amount;
  final num rate;
  final num tenor;
  final String risk;
  final num funded;
  final num total;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pct = ((funded / total) * 100).round();
    final available = total - funded;
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  purposeIcons[purpose] ?? '💰',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(purpose, style: AppText.h4),
                          Text(borrower, style: AppText.caption),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RiskBadge(level: risk),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Amount', style: AppText.caption.copyWith(fontSize: 11)),
                    Text(formatNPR(amount), style: AppText.amount),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('Interest', style: AppText.caption.copyWith(fontSize: 11)),
                    Text(
                      '$rate% p.a.',
                      style: AppText.amount.copyWith(color: AppColors.teal),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Tenor', style: AppText.caption.copyWith(fontSize: 11)),
                    Text('${tenor}mo', style: AppText.amount),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ProgressBar(value: funded.toDouble(), max: total.toDouble()),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$pct% funded', style: AppText.caption),
              Text(
                '${formatNPR(available)} left',
                style: AppText.caption.copyWith(
                  color: AppColors.teal,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AppTag extends StatelessWidget {
  const AppTag({
    super.key,
    required this.label,
    this.color = AppColors.teal,
    this.bg = AppColors.tealLight,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: kInter,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontFamily: kInter,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
                letterSpacing: 0.7,
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}

class AppToggle extends StatelessWidget {
  const AppToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.teal : AppColors.border,
          borderRadius: BorderRadius.circular(14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
