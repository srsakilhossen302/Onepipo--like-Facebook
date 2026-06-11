import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketService {
  io.Socket? _socket;

  void connect(String url) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(
      url,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .build(),
    );

    _socket!.onConnect((_) {
      print('Socket connection established.');
    });

    _socket!.onDisconnect((_) {
      print('Socket connection lost.');
    });

    _socket!.onConnectError((data) {
      print('Socket connect error: $data');
    });
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
