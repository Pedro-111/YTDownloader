import 'package:dart_api_download_video/dart_video_server.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'dart:io';

Future<void> startServer(int port) async {
  final server = VideoServer();

  final handler = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addHandler(server.router);

  final ip = InternetAddress.anyIPv4;

  try {
    final serverInstance = await io.serve(handler, ip, port);
    print('Server running on port ${serverInstance.port}');
  } catch (e) {
    print('Server failed to start: $e');
  }
}
