import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BlogEditor extends StatelessWidget {
  TextEditingController controller = TextEditingController();
  String hintText;
  BlogEditor({super.key, required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
      ),
      maxLines:
          null, // to enable new lines in textformfield when the text exceds, the textformfield will expands....
      validator: (value) {
        if (value!.isEmpty) {
          return '$hintText is missing';
        }
        return null;
      },
    );
  }
}
