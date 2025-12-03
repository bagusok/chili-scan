import 'package:flutter/material.dart';

class FormInput extends StatefulWidget {
  final bool isTextArea;
  final TextEditingController? controller;
  final String label;
  final String hintText;
  final bool isPassword;

  const FormInput({
    super.key,
    required this.label,
    required this.hintText,
    this.isTextArea = false,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<FormInput> createState() => _FormInputState();
}

class _FormInputState extends State<FormInput> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        TextField(
          controller: widget.controller,
          maxLines: widget.isTextArea ? 5 : 1,
          maxLength: null,
          obscureText: widget.isPassword && !_isVisible ? true : false,
          keyboardType: widget.isTextArea
              ? TextInputType.multiline
              : TextInputType.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _isVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isVisible = !_isVisible;
                      });
                    },
                  )
                : null,
          ),
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}
