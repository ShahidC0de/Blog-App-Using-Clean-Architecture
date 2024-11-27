import 'dart:io';

import 'package:blog_app/features/blog/domain/usecases/uploade_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog uploadBlog;
  BlogBloc(this.uploadBlog) : super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<UploadUserBlog>(_onUploadUserBlog);
  }
  void _onUploadUserBlog(UploadUserBlog event, Emitter<BlogState> emit) async {
    final response = await uploadBlog(
      UploadBlogParams(
        posterId: event.posterId,
        title: event.title,
        content: event.content,
        image: event.image,
        topics: event.topics,
      ),
    );
    response.fold((failure) {
      debugPrint(failure.message);
      emit(BlogFailure(failure.message));
    }, (r) {
      emit(BlogSuccess());
    });
  }
}
