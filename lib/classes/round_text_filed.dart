import 'package:flutter/material.dart';
import 'package:wjob/cammon/color_extension.dart';

class RoundTextFiled extends StatefulWidget {
  const RoundTextFiled({
    super.key,
    this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.readOnly = false, 
  });

  final TextEditingController? controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool readOnly;

  @override
  _RoundTextFiledState createState() => _RoundTextFiledState();
}

class _RoundTextFiledState extends State<RoundTextFiled> {
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    isPasswordVisible = !widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width : 342,
      height : 55 ,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), 
      ),
      child: TextFormField(
        autocorrect: false,
        controller: widget.controller,
        obscureText: widget.obscureText ? !isPasswordVisible : false,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        readOnly: widget.readOnly,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 5),
          border: UnderlineInputBorder(
                        borderSide: BorderSide(color: TColor.placeholder), 
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(widget.prefixIcon, color: TColor.placeholder)
              : null,
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: TColor.placeholder,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: TColor.placeholder,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}
