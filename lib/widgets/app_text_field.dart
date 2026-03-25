import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';
import '../utils/animations.dart';

enum AppTextFieldType {
  standard,
  outlined,
  filled,
}

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final EdgeInsetsGeometry? contentPadding;
  final AppTextFieldType type;
  final String? helperText;
  final String? errorText;
  final bool showErrorAnimation;
  final bool showSuccessAnimation;
  final bool showCharacterCount;
  final bool autovalidate;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;

  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.prefix,
    this.suffix,
    this.prefixIcon,
    this.suffixIcon,
    this.contentPadding,
    this.type = AppTextFieldType.standard,
    this.helperText,
    this.errorText,
    this.showErrorAnimation = true,
    this.showSuccessAnimation = true,
    this.showCharacterCount = false,
    this.autovalidate = false,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 8.0,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _hasFocus = false;
  String? _errorText;
  bool _isValid = false;
  late AnimationController _animationController;
  late Animation<double> _errorAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
    _errorText = widget.errorText;

    // Set up animation controller for error state
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _errorAnimation = Tween<double>(begin: 0.0, end: 5.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Validate initial value if autovalidate is true
    if (widget.autovalidate &&
        widget.validator != null &&
        _controller.text.isNotEmpty) {
      _validate(_controller.text);
    }
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null && widget.controller != _controller) {
      _controller.dispose();
      _controller = widget.controller!;
    }
    if (widget.focusNode != null && widget.focusNode != _focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      _focusNode = widget.focusNode!;
      _focusNode.addListener(_handleFocusChange);
    }
    if (widget.errorText != oldWidget.errorText) {
      setState(() {
        _errorText = widget.errorText;
      });
      if (_errorText != null && widget.showErrorAnimation) {
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
    if (!_hasFocus && widget.validator != null) {
      _validate(_controller.text);
    }
  }

  void _validate(String value) {
    if (widget.validator != null) {
      final error = widget.validator!(value);
      setState(() {
        _errorText = error;
        _isValid = error == null;
      });

      if (error != null && widget.showErrorAnimation) {
        _animationController.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Determine colors based on state and theme
    final Color labelColor = _hasFocus
        ? theme.colorScheme.primary
        : _errorText != null
            ? theme.colorScheme.error
            : theme.colorScheme.onSurface.withOpacity(0.6);

    final Color borderColor = _hasFocus
        ? theme.colorScheme.primary
        : _errorText != null
            ? theme.colorScheme.error
            : widget.borderColor ??
                theme.colorScheme.onSurface.withOpacity(0.3);

    final Color fillColor = widget.fillColor ??
        (_hasFocus
            ? theme.colorScheme.primary.withOpacity(0.05)
            : theme.colorScheme.surface);

    // Build input decoration based on field type
    InputDecoration decoration;

    switch (widget.type) {
      case AppTextFieldType.outlined:
        decoration = InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helperText,
          errorText: _errorText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffixIcon(),
          prefix: widget.prefix,
          suffix: widget.suffix,
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingMedium,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          filled: true,
          fillColor: fillColor,
          labelStyle: TextStyle(color: labelColor),
          counterText: widget.showCharacterCount ? null : '',
        );
        break;

      case AppTextFieldType.filled:
        decoration = InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helperText,
          errorText: _errorText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffixIcon(),
          prefix: widget.prefix,
          suffix: widget.suffix,
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingMedium,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
          ),
          filled: true,
          fillColor: fillColor,
          labelStyle: TextStyle(color: labelColor),
          counterText: widget.showCharacterCount ? null : '',
        );
        break;

      case AppTextFieldType.standard:
      default:
        decoration = InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          helperText: widget.helperText,
          errorText: _errorText,
          prefixIcon: widget.prefixIcon,
          suffixIcon: _buildSuffixIcon(),
          prefix: widget.prefix,
          suffix: widget.suffix,
          contentPadding: widget.contentPadding ??
              const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMedium,
                vertical: AppTheme.spacingSmall,
              ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          labelStyle: TextStyle(color: labelColor),
          counterText: widget.showCharacterCount ? null : '',
        );
        break;
    }

    // Build the text field with error animation if needed
    Widget textField = TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      onChanged: (value) {
        if (widget.onChanged != null) {
          widget.onChanged!(value);
        }
        if (widget.autovalidate && widget.validator != null) {
          _validate(value);
        }
      },
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onSubmitted,
      validator: widget.validator,
      inputFormatters: widget.inputFormatters,
      decoration: decoration,
      style: theme.textTheme.bodyLarge,
    );

    // Apply error shake animation if needed
    if (_errorText != null && widget.showErrorAnimation) {
      return AnimatedBuilder(
        animation: _errorAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _errorAnimation.value * sin(_errorAnimation.value * 3),
              0.0,
            ),
            child: child,
          );
        },
        child: textField,
      );
    }

    return textField;
  }

  Widget? _buildSuffixIcon() {
    // If we already have a custom suffix icon, use that
    if (widget.suffixIcon != null) {
      return widget.suffixIcon;
    }

    // Show validation state icons if appropriate
    if (widget.validator != null && _controller.text.isNotEmpty) {
      if (_errorText != null) {
        return Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        );
      } else if (_isValid && widget.showSuccessAnimation) {
        return Icon(
          Icons.check_circle_outline,
          color: Theme.of(context).colorScheme.secondary,
        );
      }
    }

    return null;
  }
}
