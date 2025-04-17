import 'package:flutter/material.dart';
import 'package:wjob/cammon/color_extension.dart';
import 'package:wjob/classes/round_text_filed.dart';
import 'package:wjob/classes/userinfo.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:wjob/view/apply_question.dart';

class UserProfileBottomSheet extends StatefulWidget {
  final UserInfo user;

  UserProfileBottomSheet({required this.user});

  @override
  _UserProfileBottomSheetState createState() => _UserProfileBottomSheetState();
}

class _UserProfileBottomSheetState extends State<UserProfileBottomSheet> {
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;
  PhoneNumber selectedCountry = PhoneNumber(isoCode: 'TN', dialCode: '+216');
  
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.user.email);
    phoneNumberController = TextEditingController(text: widget.user.phoneNumber);
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Drag indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 12,),
                // Profile picture
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(widget.user.picture),
                ),
                SizedBox(height: 10),
                // Name
                Text(
                  widget.user.name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Resume
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  child: Text(
                    widget.user.resume,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                SizedBox(height: 10,),
                // Email field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text("Email", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                RoundTextFiled(
                  controller: emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 10,),
                // Phone number input
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Phone Number", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 1),
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        selectedCountry = number;
                      });
                    },
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.DIALOG, 
                      useBottomSheetSafeArea: true,
                      setSelectorButtonAsPrefixIcon: true,
                      leadingPadding: 10,
                    ),
                    initialValue: selectedCountry,
                    formatInput: true,
                    keyboardType: TextInputType.number,
                    autoValidateMode: AutovalidateMode.onUserInteraction,
                    textFieldController: phoneNumberController,
                    inputDecoration: InputDecoration(
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: TColor.placeholder), 
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                      hintText: "Enter your phone number",
                    ),
                  ),
                ),
                SizedBox(height: 28),
                // Next button
                _buildNextButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ApplyQuestion()),
      );
      },
      child: Container(
        width: 150,
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: TColor.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            "Next",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
