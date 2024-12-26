import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'utils.dart';

class VideoServer {
  static const int BUFFER_SIZE = 81920;
  final String ytDlpPath;
  final String ffmpegPath;

  VideoServer()
      : ytDlpPath = path.join(Directory.current.path, 'bin', 'Tools', 'yt-dlp.exe'),
        ffmpegPath = path.join(Directory.current.path, 'bin', 'Tools', 'ffmpeg.exe');

  Router get router {
    final router = Router();

    // Video download endpoint with quality selection
    router.get('/download', _handleVideoDownload);

    // Audio download endpoint
    router.get('/audio', _handleAudioDownload);

    // Get available formats
    router.get('/formats', _handleGetFormats);

    return router;
  }

  Future<shelf.Response> _handleVideoDownload(shelf.Request request) async {
    try {
      final url = request.url.queryParameters['url'];
      final quality = request.url.queryParameters['quality'] ?? 'best';

      if (url == null) {
        return shelf.Response.badRequest(
          body: json.encode({'error': 'URL parameter is required'}),
        );
      }

      // Normalize the YouTube URL
      final normalizedUrl = normalizeYouTubeUrl(url);

      final tempDir = await Directory.systemTemp.createTemp('video_download_');
      final videoPath = path.join(tempDir.path, 'video.mp4');
      final audioPath = path.join(tempDir.path, 'audio.m4a');
      final outputPath = path.join(tempDir.path, 'output.mp4');

      try {
        // Get video info first
        final videoInfo = await _getVideoInfo(normalizedUrl);
        final title =
            sanitizeFilename(videoInfo['title'] as String? ?? 'video');

        // Download video and audio separately
        await _downloadVideoComponent(normalizedUrl, videoPath, quality, true);
        await _downloadVideoComponent(normalizedUrl, audioPath, 'bestaudio', false);

        // Combine video and audio
        await _combineVideoAudio(videoPath, audioPath, outputPath);

        // Stream the file back to client
        final file = File(outputPath);
        final stream = file.openRead().transform(
              StreamTransformer.fromHandlers(
                handleData: (data, sink) {
                  sink.add(data);
                },
                handleDone: (sink) async {
                  sink.close();
                  // Cleanup temp files
                  await tempDir.delete(recursive: true);
                },
              ),
            );

        return shelf.Response.ok(
          stream,
          headers: {
            'Content-Type': 'video/mp4',
            'Content-Disposition': 'attachment; filename="$title.mp4"',
          },
        );
      } catch (e) {
        await tempDir.delete(recursive: true);
        rethrow;
      }
    } catch (e) {
      return shelf.Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<shelf.Response> _handleAudioDownload(shelf.Request request) async {
    try {
      final url = request.url.queryParameters['url'];
      final format = request.url.queryParameters['format'] ?? 'mp3';

      if (url == null) {
        return shelf.Response.badRequest(
          body: json.encode({'error': 'URL parameter is required'}),
        );
      }

      // Normalize the YouTube URL
      final normalizedUrl = normalizeYouTubeUrl(url);

      final tempDir = await Directory.systemTemp.createTemp('audio_download_');
      final outputPath = path.join(tempDir.path, 'audio.$format');

      try {
        final videoInfo = await _getVideoInfo(normalizedUrl);
        final title =
            sanitizeFilename(videoInfo['title'] as String? ?? 'audio');

        await _downloadAudio(normalizedUrl, outputPath, format);

        final file = File(outputPath);
        final stream = file.openRead().transform(
              StreamTransformer.fromHandlers(
                handleData: (data, sink) {
                  sink.add(data);
                },
                handleDone: (sink) async {
                  sink.close();
                  await tempDir.delete(recursive: true);
                },
              ),
            );

        final mimeType = getAudioMimeType(format);
        return shelf.Response.ok(
          stream,
          headers: {
            'Content-Type': mimeType,
            'Content-Disposition': 'attachment; filename="$title.$format"',
          },
        );
      } catch (e) {
        await tempDir.delete(recursive: true);
        rethrow;
      }
    } catch (e) {
      return shelf.Response.internalServerError(
        body: json.encode({'error': e.toString()}),
      );
    }
  }

  Future<Map<String, dynamic>> _getVideoInfo(String url) async {
    print('yt-dlp path: $ytDlpPath'); // Debugging statement
    print('Current directory: ${Directory.current.path}'); // Debugging statement
    final result = await Process.run(
      ytDlpPath,
      ['--dump-json', url],
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to get video info: ${result.stderr}');
    }

    return json.decode(result.stdout as String);
  }

  Future<void> _downloadVideoComponent(
      String url, String outputPath, String format, bool isVideo) async {
    final formatArg = isVideo ? 'bestvideo[height<=?$format]' : format;

    final result = await Process.run(
      ytDlpPath,
      [
        '-f',
        formatArg,
        '-o',
        outputPath,
        url,
      ],
    );

    if (result.exitCode != 0) {
      throw Exception(
          'Failed to download ${isVideo ? "video" : "audio"}: ${result.stderr}');
    }
  }

  Future<void> _downloadAudio(
      String url, String outputPath, String format) async {
    final result = await Process.run(
      ytDlpPath,
      [
        '--extract-audio',
        '--audio-format',
        format,
        '-o',
        outputPath,
        url,
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to download audio: ${result.stderr}');
    }
  }

  Future<void> _combineVideoAudio(
      String videoPath, String audioPath, String outputPath) async {
    final result = await Process.run(
      ffmpegPath,
      [
        '-i',
        videoPath,
        '-i',
        audioPath,
        '-c:v',
        'copy',
        '-c:a',
        'aac',
        '-strict',
        'experimental',
        outputPath,
      ],
    );

    if (result.exitCode != 0) {
      throw Exception('Failed to combine video and audio: ${result.stderr}');
    }
  }

  Future<shelf.Response> _handleGetFormats(shelf.Request request) async {
    final formats = {
      'video': {
        'formats': ['mp4', 'webm', 'mkv'],
        'qualities': [
          {'label': '144p', 'value': '144'},
          {'label': '240p', 'value': '240'},
          {'label': '360p', 'value': '360'},
          {'label': '480p', 'value': '480'},
          {'label': '720p', 'value': '720'},
          {'label': '1080p', 'value': '1080'},
          {'label': '1440p', 'value': '1440'},
          {'label': '2160p (4K)', 'value': '2160'},
        ],
      },
      'audio': {
        'formats': ['mp3', 'm4a', 'opus', 'wav'],
      },
    };

    return shelf.Response.ok(
      json.encode(formats),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
