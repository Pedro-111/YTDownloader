import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<void> downloadVideo(
      {required String url, required String quality}) async {
    final response = await http
        .get(Uri.parse('$baseUrl/download?url=$url&quality=$quality'));
    if (response.statusCode == 200) {
      print('Video downloaded successfully');
    } else {
      print('Failed to download video: ${response.statusCode}');
    }
  }

  Future<void> downloadAudio(
      {required String url, required String format}) async {
    final response =
        await http.get(Uri.parse('$baseUrl/audio?url=$url&format=$format'));
    if (response.statusCode == 200) {
      print('Audio downloaded successfully');
    } else {
      print('Failed to download audio: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getFormats() async {
    final response = await http.get(Uri.parse('$baseUrl/formats'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load formats');
    }
  }
}
