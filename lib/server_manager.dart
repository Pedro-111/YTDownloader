import 'dart:isolate';
import 'server.dart';

class ServerManager {
  static Future<void> startServer(int port) async {
    // Create a receive port for communication
    final receivePort = ReceivePort();
    
    try {
      await Isolate.spawn(
        isolateFunction,
        IsolateData(port, receivePort.sendPort),
      );
      
      // Wait for confirmation from the isolate
      await receivePort.first;
    } catch (e) {
      print('Failed to start server in isolate: $e');
      rethrow;
    } finally {
      receivePort.close();
    }
  }
}

// Helper class to pass data to isolate
class IsolateData {
  final int port;
  final SendPort sendPort;
  
  IsolateData(this.port, this.sendPort);
}

// Isolate entry point function
void isolateFunction(IsolateData data) async {
  try {
    await startServer(data.port);
    data.sendPort.send('Server started successfully');
  } catch (e) {
    data.sendPort.send('Failed to start server: $e');
  }
}