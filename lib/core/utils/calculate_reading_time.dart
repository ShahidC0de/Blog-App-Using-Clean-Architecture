int calculateReadingTime(String content) {
  final wordCount = content.split(RegExp(r'\s+')).length;
  // average person reading speed is 200-300 words per minute
  // to calculate the speed d/t => readingTime/ wordCount

  final readingTime = wordCount / 225;
  return readingTime
      .ceil(); // toInt max/min value can be achieved, but we want always max value so Ceil.
}
