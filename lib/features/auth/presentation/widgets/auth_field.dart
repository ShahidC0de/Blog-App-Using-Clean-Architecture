import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final TextEditingController controller;
  final String hintext;
  final bool obsecureText;
  const AuthField(
      {this.obsecureText =
          false, // default if user dont specify, otherwise user way.
      required this.controller,
      required this.hintext,
      super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obsecureText,
      decoration: InputDecoration(
        hintText: hintext,
      ),
      validator: (value) {
        if (value!.isEmpty) {
          // if there is no content in field then
          return "$hintext is empty";
        } else {
          // everything is alright!
          return null;
        }
      },
    );
  }
}
