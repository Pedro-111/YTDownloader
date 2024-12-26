
String normalizeYouTubeUrl(String url) {
  // Regular expression to match YouTube video IDs
  final RegExp youtubeIdRegex = RegExp(
    r'^(?:https?:\/\/)?(?:www\.)?(?:youtube\.com\/(?:[^\/\n\s]+\/\S+\/|(?:v|e(?:mbed)?)\/|\S*?[?&]v=)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    caseSensitive: false,
  );

  final match = youtubeIdRegex.firstMatch(url);
  if (match != null && match.groupCount >= 1) {
    final videoId = match.group(1);
    return 'https://www.youtube.com/watch?v=$videoId';
  }

  // If no match is found, return the original URL
  return url;
}

String sanitizeFilename(String filename) {
  // Remove emojis from the filename
  final RegExp emojiRegex = RegExp(
    r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])',
  );
  return filename.replaceAll(emojiRegex, '_');
}

String getAudioMimeType(String format) {
  switch (format) {
    case 'mp3':
      return 'audio/mpeg';
    case 'm4a':
      return 'audio/mp4';
    case 'opus':
      return 'audio/opus';
    case 'wav':
      return 'audio/wav';
    default:
      return 'application/octet-stream';
  }
}
