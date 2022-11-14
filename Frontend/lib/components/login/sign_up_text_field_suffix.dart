import 'package:flutter/material.dart';
import 'package:homealone/constants.dart';
import 'package:sizer/sizer.dart';

class SignUpTextFieldSuffix extends StatelessWidget {
  const SignUpTextFieldSuffix({
    Key? key,
    required this.paddings,
    required this.keyboardtypes,
    required this.hinttexts,
    required this.helpertexts,
    required this.onchangeds,
    required this.validations,
    this.suffix,
  }) : super(key: key);

  final paddings;
  final keyboardtypes;
  final hinttexts;
  final helpertexts;
  final onchangeds;
  final validations;
  final suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddings,
      child: TextFormField(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        autocorrect: false,
        validator: validations,
        keyboardType: keyboardtypes,
        textInputAction: TextInputAction.done,
        cursorColor: bColor,
        decoration: InputDecoration(
          isCollapsed: true,
          hintText: hinttexts,
          helperText: helpertexts,
          contentPadding: EdgeInsets.fromLTRB(5.w, 1.25.h, 5.w, 1.25.h),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: b25Color),
          ),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            borderSide: BorderSide(color: bColor),
          ),
          suffix: suffix,
        ),
        onChanged: onchangeds,
      ),
    );
  }
}
