import 'package:blog_app/core/error/exceptions.dart';
import 'package:blog_app/features/blog/data/models/blog_model.dart';
import 'package:hive/hive.dart';

abstract interface class BlogLocalDatasource {
  void uploadAllBlogs({required List<BlogModel> blogs});
  List<BlogModel> loadAllBlogs();
}

class BlogLocalDatasourceImpl implements BlogLocalDatasource {
  final Box box;
  BlogLocalDatasourceImpl(this.box);
  @override
  List<BlogModel> loadAllBlogs() {
    List<BlogModel> blogs = [];
    for (int i = 0; i < box.length; i++) {
      final blogData = box.get(i.toString());
      if (blogData != null) {
        try {
          blogs.add(BlogModel.fromJson(Map<String, dynamic>.from(blogData)));
        } catch (e) {
          throw ServerException(e.toString());
        }
      }
    }
    return blogs;
  }

  @override
  void uploadAllBlogs({required List<BlogModel> blogs}) {
    box.clear();
    for (int i = 0; i < blogs.length; i++) {
      box.put(i.toString(), blogs[i].toJson());
    }
  }
}
