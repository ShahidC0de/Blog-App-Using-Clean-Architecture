import 'dart:io';

import 'package:blog_app/core/common/app_user/cubit/app_user_cubit.dart';
import 'package:blog_app/core/common/widgets/loader.dart';
import 'package:blog_app/core/theme/app_pallete.dart';
import 'package:blog_app/core/utils/pick_image.dart';
import 'package:blog_app/core/utils/show_snackbar.dart';
import 'package:blog_app/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_app/features/blog/presentation/pages/home_screen.dart';
import 'package:blog_app/features/blog/presentation/widgets/blog_editor.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNewBlogScreen extends StatefulWidget {
  static route() => MaterialPageRoute(
      builder: (context) =>
          const AddNewBlogScreen()); // this is defining custom route for this page.
  const AddNewBlogScreen({super.key});

  @override
  State<AddNewBlogScreen> createState() => _AddNewBlogScreenState();
}

class _AddNewBlogScreenState extends State<AddNewBlogScreen> {
  final titleController = TextEditingController();
  final blogController = TextEditingController();
  final formkey = GlobalKey<FormState>();
  List<String> selectedTopics = [];
  File? image;
  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  void uploadBlog() {
    if (formkey.currentState!.validate() &&
        selectedTopics.isNotEmpty &&
        image != null) {
      final posterId = (context.read<AppUserCubit>().state as AppUserLoggedIn)
          .user
          .id; // so this allows us to retrieve the current user id
      context.read<BlogBloc>().add(UploadUserBlog(
            posterId: posterId,
            title: titleController.text.trim(),
            content: blogController.text.trim(),
            image: image!,
            topics: selectedTopics,
          ));
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    blogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                debugPrint('Submitted Button Clicked');
                uploadBlog();
              },
              icon: const Icon(Icons.done_rounded)),
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.message);
          } else if (state is BlogSuccess) {
            Navigator.of(context)
                .pushAndRemoveUntil(HomeScreen.route(), (route) => false);
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formkey,
                child: Column(
                  children: [
                    image != null
                        ? GestureDetector(
                            onTap: selectImage,
                            child: SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                  ),
                                )),
                          ) // if image is null then the dotted border with gesture detector, otherwise the image
                        : GestureDetector(
                            onTap: () async {
                              debugPrint('Clicked on select image');
                              selectImage(); // this is not working tomorrow work...
                            },
                            child: DottedBorder(
                              color: AppPallete.borderColor,
                              dashPattern: const [10, 4],
                              radius: const Radius.circular(10),
                              borderType: BorderType.RRect,
                              strokeCap: StrokeCap.round,
                              child: const SizedBox(
                                height: 150,
                                width: double.infinity,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.folder_open,
                                      size: 40,
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Text(
                                      'Select your image',
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 20,
                    ),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'Technology',
                          'Business',
                          'Programming',
                          'Entertainment'
                        ]
                            .map((e) => Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (selectedTopics.contains(e)) {
                                        selectedTopics.remove(e);
                                      } else {
                                        selectedTopics.add(e);
                                      }
                                      setState(() {});
                                    },
                                    child: Chip(
                                      label: Text(e),
                                      color: selectedTopics.contains(e)
                                          ? const WidgetStatePropertyAll(
                                              AppPallete.gradient1)
                                          : null, // null means default color in themedata
                                      side: selectedTopics.contains(
                                              e) // if selectedTopics contain e then default border which is none, otherwise bordercolor.
                                          ? null
                                          : const BorderSide(
                                              color: AppPallete.borderColor),
                                    ),
                                  ),
                                ))
                            .toList(),
                        // what it does that like a loop it takes each element which is 'e' and map it to a chip the chip is a widget.
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    BlogEditor(
                        controller: titleController, hintText: 'Blog Title'),
                    const SizedBox(
                      height: 10,
                    ),
                    BlogEditor(
                        controller: blogController, hintText: 'Blog content'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
