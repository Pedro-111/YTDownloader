<div align="center">
  <img src="https://raw.githubusercontent.com/dart-lang/site-shared/master/src/assets/shared/dart/icon/64.png" alt="Dart Logo" width="100"/>

# 🎥 YouTube Video/Audio Downloader Server

A powerful server application built using [Shelf](https://pub.dev/packages/shelf) for downloading YouTube content. Supports high-quality video downloads and audio extraction with multiple format options.

[![Dart SDK](https://img.shields.io/badge/Dart-SDK-blue)](https://dart.dev/get-dart)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue)](https://www.docker.com/get-started)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
</div>

## ✨ Features

- 🎬 Video download with quality selection (144p to 4K)
- 🎵 Audio extraction in multiple formats (MP3, M4A, OPUS, WAV)
- 🌈 Proper filename handling with support for Unicode characters and emojis
- 🚀 Buffered streaming for efficient memory usage
- 🐋 Docker support

## 📋 Prerequisites

- 🎯 [Dart SDK](https://dart.dev/get-dart)
- 📥 [yt-dlp](https://github.com/yt-dlp/yt-dlp) executable in `bin/Tools/yt-dlp.exe`
- 🎞️ [FFmpeg](https://ffmpeg.org/) executable in `bin/Tools/ffmpeg.exe`

## 🔌 API Endpoints

### 📹 GET /download
Downloads a video with optional quality selection.
```http
GET /download?url={youtube_url}&quality={video_quality}
```
- Parameters:
  - `url`: YouTube video URL (required)
  - `quality`: Video quality (optional, defaults to 'best')
  
### 🎧 GET /audio
Downloads audio in the specified format.
```http
GET /audio?url={youtube_url}&format={audio_format}
```
- Parameters:
  - `url`: YouTube video URL (required)
  - `format`: Audio format (optional, defaults to 'mp3')

### 📋 GET /formats
Returns available video and audio formats.
```http
GET /formats
```

## 🚀 Running the Server

### 💻 Running with the Dart SDK

You can run the server with a custom port (default is 8080):

```bash
$ dart run bin/main.dart 8080
✨ Server listening on port 8080
```

Example usage:

```bash
# 📹 Download video
$ curl "http://localhost:8080/download?url=https://www.youtube.com/watch?v=VIDEO_ID&quality=720"

# 🎵 Download audio
$ curl "http://localhost:8080/audio?url=https://www.youtube.com/watch?v=VIDEO_ID&format=mp3"

# 📋 Get available formats
$ curl "http://localhost:8080/formats"
```

### 🐋 Running with Docker

If you have [Docker Desktop](https://www.docker.com/get-started) installed:

```bash
# 🏗️ Build the image
$ docker build . -t youtube-downloader

# 🚀 Run the container
$ docker run -it -p 8080:8080 youtube-downloader
✨ Server listening on port 8080
```

## 🔧 Frontend Integration

### 📱 Using the API Service in Dart/Flutter

Add the `http` package to your `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

Create an API service class to interact with the server:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;
  
  ApiService({required this.baseUrl});
  
  // 📹 Download video
  Future<void> downloadVideo({
    required String url,
    required String quality
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/download?url=$url&quality=$quality')
    );
    
    if (response.statusCode == 200) {
      print('✅ Video downloaded successfully');
    } else {
      print('❌ Failed to download video: ${response.statusCode}');
    }
  }
  
  // 🎵 Download audio
  Future<void> downloadAudio({
    required String url,
    required String format
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/audio?url=$url&format=$format')
    );
    
    if (response.statusCode == 200) {
      print('✅ Audio downloaded successfully');
    } else {
      print('❌ Failed to download audio: ${response.statusCode}');
    }
  }
  
  // 📋 Get formats
  Future<Map<String, dynamic>> getFormats() async {
    final response = await http.get(Uri.parse('$baseUrl/formats'));
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('❌ Failed to load formats');
    }
  }
}
```

Example usage in your Flutter app:

```dart
void main() {
  final apiService = ApiService(baseUrl: 'http://localhost:8080');
  
  // 📋 Get available formats
  apiService.getFormats().then((formats) {
    print('📋 Available formats: $formats');
  });
  
  // 📹 Download video
  apiService.downloadVideo(
    url: 'https://www.youtube.com/watch?v=VIDEO_ID',
    quality: '720'
  );
  
  // 🎵 Download audio
  apiService.downloadAudio(
    url: 'https://www.youtube.com/watch?v=VIDEO_ID',
    format: 'mp3'
  );
}
```

## 📦 Response Format

### ✅ Successful Download
- 📹 Video downloads return the file with `Content-Type: video/mp4`
- 🎵 Audio downloads return the file with the appropriate audio MIME type
- 📝 Files are returned with the original video title as the filename

### ❌ Error Response
```json
{
  "error": "Error message description"
}
```

### 📋 Available Formats Response
```json
{
  "video": {
    "formats": ["mp4", "webm", "mkv"],
    "qualities": [
      {"label": "144p", "value": "144"},
      {"label": "240p", "value": "240"},
      {"label": "360p", "value": "360"},
      {"label": "480p", "value": "480"},
      {"label": "720p", "value": "720"},
      {"label": "1080p", "value": "1080"},
      {"label": "1440p", "value": "1440"},
      {"label": "2160p (4K)", "value": "2160"}
    ]
  },
  "audio": {
    "formats": ["mp3", "m4a", "opus", "wav"]
  }
}
```

## 📚 Supported Formats

### 📹 Video
- Formats: MP4, WebM, MKV
- Qualities: 144p, 240p, 360p, 480p, 720p, 1080p, 1440p, 2160p (4K)

### 🎵 Audio
- Formats: MP3, M4A, OPUS, WAV

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
<div align="center">
  Made with ❤️ using Dart
  
  [Report Bug](../../issues) · [Request Feature](../../issues)
</div>