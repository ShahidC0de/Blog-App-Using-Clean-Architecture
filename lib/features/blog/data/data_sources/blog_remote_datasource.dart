import 'dart:io';

import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class BlogRemoteDatasource {
  Future<List<BlogModel>> getAllUserBlogs();
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadImage({
    required File image,
    required BlogModel blog,
  });
}

class BlogRemoteDatasourceImpl implements BlogRemoteDatasource {
  final SupabaseClient supabaseClient;
  BlogRemoteDatasourceImpl({
    required this.supabaseClient,
  });
  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      final blogData =
          await supabaseClient.from('blogs').insert(blog.toJson()).select();
      final decodedData = BlogModel.fromJson(blogData.first);
      debugPrint('THIS IS BLOGREMOTE DATASOURCE IMPL');
      debugPrint(decodedData.toString());

      return BlogModel.fromJson(blogData.first);
    } on StorageException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadImage({
    required File image,
    required BlogModel blog,
  }) async {
    try {
      await supabaseClient.storage.from('blog_images').upload(blog.id,
          image); //uploading image, path is blog.id, from means bucket id,
      return supabaseClient.storage
          .from('blog_images')
          .getPublicUrl(blog.id); // getting the blog image url,
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
  // this is why we update blog with posterName, to store the posterName and it was not mendatory but in getting blogs we will need the name,
  // of poster so we updated only copywith function in blog model to to get this field...

  @override
  Future<List<BlogModel>> getAllUserBlogs() async {
    try {
      final blogs =
          await supabaseClient.from('blogs').select('*,profiles(name)');
      // two joint operations, first go to blogs and select all then go to profiles and fetch only name corresponding to its posterId,
      return blogs
          .map((blog) => BlogModel.fromJson(blog).copyWith(
                posterName: blog['profiles']['name'],
                // added posterName in copywith function, so it is the way to fetch the name,
              ))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
