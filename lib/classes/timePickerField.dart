import 'package:flutter/material.dart';

class TimePickerField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final String? Function(String?)? validator; 

  const TimePickerField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.validator,
  }) : super(key: key);

  @override
  _TimePickerFieldState createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      // Format time as "HH:mm" and set it to the controller
      final String formattedTime =
          "${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}";
      setState(() {
        widget.controller.text = selectedTime.format(context);
      });
    }
  }

  @override
 Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      readOnly: true,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Colors.grey[600], // Placeholder color
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.grey[200], // Background color
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25), // Rounded border
          borderSide: BorderSide.none,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.access_time, color: Color.fromARGB(255, 83, 81, 81)),
          onPressed: () => _pickTime(context),
        ),
      ),
      validator: widget.validator,
      onTap: () => _pickTime(context),
    );
  }
}