import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_client/web_socket_client.dart';

class FinnHubSocketService {
  WebSocket? socket;

  void init() {
    socket = WebSocket(
      Uri.parse("wss://ws.finnhub.io/?token=${dotenv.env['TOKEN']}"),
      timeout: Duration(seconds: 10),
    );
  }

  Stream<dynamic> listenToMessage() async* {
    await for (final message in socket!.messages) {
      // log(message);
      final Map<String, dynamic> response = jsonDecode(message);
      if (response case {"type": "ping"}) {
        continue;
      }
      yield response["data"];
    }
  }

  void close() {
    socket?.close();
  }
}
