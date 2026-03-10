import 'package:get/get_utils/get_utils.dart';
import 'package:mnjood_vendor/util/dimensions.dart';
import 'package:mnjood_vendor/util/styles.dart';
import 'package:flutter/material.dart';

class CustomButtonWidget extends StatefulWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final Color? color;
  final Color? iconColor;
  final IconData? icon;
  final double radius;
  final FontWeight? fontWeight;
  final Color? textColor;
  final bool isLoading;
  final IconData? onlyButtonIcon;
  final Color? buttonDisabledColor;
  final Color? borderColor;
  final bool isBorder;

  const CustomButtonWidget({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin,
    this.width,
    this.height,
    this.fontSize,
    this.color,
    this.icon,
    this.radius = Dimensions.radiusMedium,
    this.fontWeight,
    this.textColor,
    this.iconColor,
    this.isLoading = false,
    this.onlyButtonIcon,
    this.buttonDisabledColor,
    this.borderColor,
    this.isBorder = false,
  });

  @override
  State<CustomButtonWidget> createState() => _CustomButtonWidgetState();
}

class _CustomButtonWidgetState extends State<CustomButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    final Color backgroundColor = isDisabled
        ? (widget.buttonDisabledColor ?? Theme.of(context).hintColor.withOpacity(0.5))
        : widget.transparent
            ? Colors.transparent
            : widget.color ?? Theme.of(context).primaryColor;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading ? null : () => widget.onPressed?.call(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            width: widget.width,
            height: widget.height ?? 52,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(widget.radius),
              border: widget.isBorder
                  ? Border.all(
                      color: widget.borderColor ?? Theme.of(context).primaryColor,
                      width: 1.5,
                    )
                  : null,
              boxShadow: !widget.transparent && !isDisabled
                  ? [
                      BoxShadow(
                        color: (widget.color ?? Theme.of(context).primaryColor)
                            .withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: widget.isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        ),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Text(
                          'loading'.tr,
                          style: robotoMedium.copyWith(color: Colors.white),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            color: widget.iconColor ??
                                (widget.transparent
                                    ? Theme.of(context).primaryColor
                                    : Colors.white),
                            size: 20,
                          ),
                          const SizedBox(width: Dimensions.paddingSizeSmall),
                        ],
                        widget.onlyButtonIcon != null
                            ? Icon(
                                widget.onlyButtonIcon,
                                color: Colors.white,
                                size: 28,
                              )
                            : Text(
                                widget.buttonText,
                                textAlign: TextAlign.center,
                                style: robotoBold.copyWith(
                                  color: widget.textColor ??
                                      (widget.transparent
                                          ? Theme.of(context).primaryColor
                                          : Colors.white),
                                  fontSize:
                                      widget.fontSize ?? Dimensions.fontSizeLarge,
                                  fontWeight: widget.fontWeight ?? FontWeight.w600,
                                ),
                              ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
