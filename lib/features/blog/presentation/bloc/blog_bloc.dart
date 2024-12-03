import 'dart:io';

import 'package:blog_app/core/usecase/usecase.dart';
import 'package:blog_app/features/blog/domain/entities/blog.dart';
import 'package:blog_app/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_app/features/blog/domain/usecases/uploade_blog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'blog_event.dart';
part 'blog_state.dart';

class BlogBloc extends Bloc<BlogEvent, BlogState> {
  final UploadBlog _uploadBlog;
  final GetAllBlogs _getAllBlogs;
  BlogBloc({
    required UploadBlog uploadBlog,
    required GetAllBlogs getAllBlogs,
  })  : _uploadBlog = uploadBlog,
        _getAllBlogs = getAllBlogs,
        super(BlogInitial()) {
    on<BlogEvent>((event, emit) => emit(BlogLoading()));
    on<UploadUserBlog>(_onUploadUserBlog);
    on<BlogFetchAllBlogs>(_blogFetchAllBlogs);
  }
  void _blogFetchAllBlogs(
      BlogFetchAllBlogs event, Emitter<BlogState> emit) async {
    final response = await _getAllBlogs(NoParams());
    response.fold((failure) {
      emit(BlogFailure(failure.message));
    }, (r) {
      emit(BlogsReceivedSuccess(r));
    });
  }

  void _onUploadUserBlog(UploadUserBlog event, Emitter<BlogState> emit) async {
    final response = await _uploadBlog(
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
      emit(BlogUploadSuccess());
    });
  }
}
