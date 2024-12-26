import 'package:dart_api_download_video/server.dart' as server;

void main(List<String> arguments) async {
  int port = 8081;
  if (arguments.isNotEmpty) {
    port = int.tryParse(arguments[0]) ?? 8081;
  }
  await server.startServer(port);
}
