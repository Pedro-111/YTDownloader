
import 'dart:convert';

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
String encodeFilename(String filename) {
    // Remove invalid filesystem characters but keep Unicode characters
    final sanitized = filename.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    
    // UTF-8 encode the filename
    final bytes = utf8.encode(sanitized);
    final encoded = bytes.map((byte) => '%${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}').join('');
    
    return "filename*=UTF-8''$encoded";
  }
  String createContentDisposition(String filename) {
    // Create ASCII-only filename by removing non-ASCII characters
    final asciiFilename = filename.replaceAll(RegExp(r'[^\x20-\x7E]'), '_');
    
    // Create UTF-8 encoded filename
    final bytes = utf8.encode(filename);
    final utf8Filename = bytes.map((byte) => '%${byte.toRadixString(16).padLeft(2, '0').toUpperCase()}').join('');
    
    // Return Content-Disposition with both ASCII and UTF-8 filenames
    return 'attachment; filename="$asciiFilename"; filename*=UTF-8\'\'$utf8Filename';
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
