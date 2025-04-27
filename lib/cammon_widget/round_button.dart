import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  const RoundButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.gradient,
    this.borderColor = Colors.transparent,
    this.textColor = Colors.white,
    this.isLoading = false,
  });

  final VoidCallback onPressed;
  final String title;
  final Gradient? gradient; 
  final Color borderColor;
  final Color textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: 343,
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: gradient, 
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: isLoading
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              )
            : Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
