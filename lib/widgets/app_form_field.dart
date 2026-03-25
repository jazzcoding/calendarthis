import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

/// A form field with improved validation feedback
class AppFormField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? helperText;
  final String? errorText;
  final bool isRequired;
  final bool isValid;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment alignment;

  const AppFormField({
    super.key,
    required this.label,
    required this.child,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.isValid = false,
    this.padding = const EdgeInsets.only(bottom: AppTheme.spacingMedium),
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          // Label row with required indicator and validation status
          Row(
            children: [
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: errorText != null 
                      ? theme.colorScheme.error 
                      : theme.colorScheme.onSurface,
                ),
              ),
              if (isRequired)
                Text(
                  ' *',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const Spacer(),
              // Show validation status
              if (errorText == null && isValid)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: theme.colorScheme.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Valid',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSmall),
          
          // Form field
          child,
          
          // Helper text or error message
          if (errorText != null || helperText != null)
            Padding(
              padding: const EdgeInsets.only(
                top: AppTheme.spacingTiny,
                left: AppTheme.spacingSmall,
              ),
              child: Text(
                errorText ?? helperText ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: errorText != null
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
