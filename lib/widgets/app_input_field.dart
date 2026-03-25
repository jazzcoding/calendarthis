import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_theme.dart';

enum AppInputFieldType {
  text,
  email,
  password,
  number,
  phone,
  multiline,
  search,
  date,
  time,
}

class AppInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final AppInputFieldType type;
  final bool isRequired;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;
  final String? Function(String?)? validator;

  const AppInputField({
    super.key,
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.type = AppInputFieldType.text,
    this.isRequired = false,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.onChanged,
    this.onSubmitted,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.validator,
  });

  @override
  State<AppInputField> createState() => _AppInputFieldState();
}

class _AppInputFieldState extends State<AppInputField> {
  late TextEditingController _controller;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Configure input properties based on type
    TextInputType keyboardType;
    List<TextInputFormatter> formatters = widget.inputFormatters ?? [];
    bool obscureText = false;
    Widget? suffix;
    
    switch (widget.type) {
      case AppInputFieldType.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case AppInputFieldType.password:
        keyboardType = TextInputType.visiblePassword;
        obscureText = _obscureText;
        suffix = IconButton(
          icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: () {
            setState(() {
              _obscureText = !_obscureText;
            });
          },
        );
        break;
      case AppInputFieldType.number:
        keyboardType = TextInputType.number;
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case AppInputFieldType.phone:
        keyboardType = TextInputType.phone;
        formatters.add(FilteringTextInputFormatter.digitsOnly);
        break;
      case AppInputFieldType.multiline:
        keyboardType = TextInputType.multiline;
        break;
      case AppInputFieldType.search:
        keyboardType = TextInputType.text;
        suffix = IconButton(
          icon: const Icon(Icons.search),
          onPressed: widget.onSuffixIconPressed,
        );
        break;
      case AppInputFieldType.date:
        keyboardType = TextInputType.datetime;
        suffix = IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: widget.onSuffixIconPressed,
        );
        break;
      case AppInputFieldType.time:
        keyboardType = TextInputType.datetime;
        suffix = IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: widget.onSuffixIconPressed,
        );
        break;
      case AppInputFieldType.text:
      default:
        keyboardType = TextInputType.text;
        break;
    }
    
    // Add custom suffix icon if provided
    if (widget.suffixIcon != null) {
      suffix = IconButton(
        icon: Icon(widget.suffixIcon),
        onPressed: widget.onSuffixIconPressed,
      );
    }
    
    // Create label text with required indicator if needed
    final String labelText = widget.isRequired ? '${widget.label} *' : widget.label;
    
    return TextFormField(
      controller: _controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: widget.maxLength,
      maxLines: widget.type == AppInputFieldType.multiline ? widget.maxLines : 1,
      enabled: widget.enabled,
      focusNode: widget.focusNode,
      textInputAction: widget.textInputAction,
      inputFormatters: formatters,
      autovalidateMode: widget.autovalidateMode,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: widget.hint,
        errorText: widget.errorText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: suffix,
      ),
    );
  }
}
