part of 'blog_bloc.dart';

@immutable
sealed class BlogEvent {}

final class UploadUserBlog extends BlogEvent {
  final String posterId;
  final String title;
  final String content;
  final File image;
  final List<String> topics;
  UploadUserBlog({
    required this.posterId,
    required this.title,
    required this.content,
    required this.image,
    required this.topics,
  });
}
