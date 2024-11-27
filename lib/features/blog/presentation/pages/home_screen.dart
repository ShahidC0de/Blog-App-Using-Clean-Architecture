import 'package:blog_app/features/blog/presentation/pages/add_new_blog_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => const HomeScreen());
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                Navigator.push(
                    context,
                    AddNewBlogScreen
                        .route()); // this is custom route defined in the addnewblogscreen page.
              },
              icon: const Icon(CupertinoIcons.add_circled)),
        ],
      ),
    );
  }
}
