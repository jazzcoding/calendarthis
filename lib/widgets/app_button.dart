import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_theme.dart';

enum AppButtonType {
  primary,
  secondary,
  text,
  success,
  danger,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final AppButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final bool animateOnTap;
  final bool showSuccessAnimation;
  final bool showErrorAnimation;
  final Duration successAnimationDuration;
  final Duration errorAnimationDuration;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.animateOnTap = true,
    this.showSuccessAnimation = false,
    this.showErrorAnimation = false,
    this.successAnimationDuration = const Duration(milliseconds: 1500),
    this.errorAnimationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isSuccess = false;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSuccess() {
    setState(() {
      _isSuccess = true;
      _isError = false;
    });

    Future.delayed(widget.successAnimationDuration, () {
      if (mounted) {
        setState(() {
          _isSuccess = false;
        });
      }
    });
  }

  void _showError() {
    setState(() {
      _isSuccess = false;
      _isError = true;
    });

    Future.delayed(widget.errorAnimationDuration, () {
      if (mounted) {
        setState(() {
          _isError = false;
        });
      }
    });
  }

  void _handleTap() {
    if (widget.onPressed != null && !widget.isLoading) {
      if (widget.animateOnTap) {
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
      }

      widget.onPressed!();

      if (widget.showSuccessAnimation) {
        _showSuccess();
      }

      if (widget.showErrorAnimation) {
        _showError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine button style based on type
    Widget button;

    switch (widget.type) {
      case AppButtonType.primary:
        button = _buildElevatedButton(context);
        break;
      case AppButtonType.secondary:
        button = _buildOutlinedButton(context);
        break;
      case AppButtonType.text:
        button = _buildTextButton(context);
        break;
      case AppButtonType.success:
        button = _buildSuccessButton(context);
        break;
      case AppButtonType.danger:
        button = _buildDangerButton(context);
        break;
    }

    // Apply full width if needed
    if (widget.isFullWidth) {
      button = SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    // Apply animation
    if (widget.animateOnTap) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: button,
      );
    }

    return button;
  }

  Widget _buildElevatedButton(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.isLoading ? null : _handleTap,
      style: _getButtonStyle(context),
      child: _buildButtonContent(),
    );
  }

  Widget _buildOutlinedButton(BuildContext context) {
    return OutlinedButton(
      onPressed: widget.isLoading ? null : _handleTap,
      style: _getButtonStyle(context),
      child: _buildButtonContent(),
    );
  }

  Widget _buildTextButton(BuildContext context) {
    return TextButton(
      onPressed: widget.isLoading ? null : _handleTap,
      style: _getButtonStyle(context),
      child: _buildButtonContent(),
    );
  }

  Widget _buildSuccessButton(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: widget.isLoading ? null : _handleTap,
      style: _getButtonStyle(context).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return theme.disabledColor;
          }
          return Colors.green;
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
      child: _buildButtonContent(),
    );
  }

  Widget _buildDangerButton(BuildContext context) {
    final theme = Theme.of(context);
    return ElevatedButton(
      onPressed: widget.isLoading ? null : _handleTap,
      style: _getButtonStyle(context).copyWith(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return theme.disabledColor;
          }
          return theme.colorScheme.error;
        }),
        foregroundColor: WidgetStateProperty.all(Colors.white),
      ),
      child: _buildButtonContent(),
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context) {
    // Get base style from theme based on button type
    ButtonStyle baseStyle;
    final theme = Theme.of(context);

    switch (widget.type) {
      case AppButtonType.primary:
        baseStyle = ElevatedButton.styleFrom();
        break;
      case AppButtonType.secondary:
        baseStyle = OutlinedButton.styleFrom();
        break;
      case AppButtonType.text:
        baseStyle = TextButton.styleFrom();
        break;
      case AppButtonType.success:
        baseStyle = ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        );
        break;
      case AppButtonType.danger:
        baseStyle = ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: Colors.white,
        );
        break;
    }

    // Apply size modifications
    EdgeInsetsGeometry padding;
    double? height;

    switch (widget.size) {
      case AppButtonSize.small:
        padding = const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingTiny,
        );
        height = 36;
        break;
      case AppButtonSize.medium:
        padding = const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMedium,
          vertical: AppTheme.spacingSmall,
        );
        height = 48;
        break;
      case AppButtonSize.large:
        padding = const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingLarge,
          vertical: AppTheme.spacingMedium,
        );
        height = 56;
        break;
    }

    return baseStyle.copyWith(
      padding: WidgetStateProperty.all(padding),
      minimumSize: WidgetStateProperty.all(Size(88, height)),
    );
  }

  Widget _buildButtonContent() {
    if (widget.isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_isSuccess) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 20),
          const SizedBox(width: AppTheme.spacingSmall),
          Flexible(
            child: Text(
              'Success',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    if (_isError) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 20),
          const SizedBox(width: AppTheme.spacingSmall),
          Flexible(
            child: Text(
              'Error',
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 20),
          const SizedBox(width: AppTheme.spacingSmall),
          Flexible(
            child: Text(
              widget.label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      );
    }

    return Text(
      widget.label,
      overflow: TextOverflow.ellipsis,
      maxLines: 1,
    );
  }
}
