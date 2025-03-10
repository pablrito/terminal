import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:oktoast/oktoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HubConnection _hubConnection;
  String? _device = "";
  String _status = "Initializing...";

  @override
  void initState() {
    super.initState();
    initializeSignal();
  }

  Future<void> initializeSignal() async {
    const signalRUrl = 'https://automate20250117155727.azurewebsites.net/terminal';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          "$signalRUrl?X-Auth-Token=abc",
          HttpConnectionOptions(
            transport: HttpTransportType.webSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();

    setState(() {
      _status = "Ready to Connect";
    });

    _hubConnection.onclose((error) {
      setState(() {
        _status = "Disconnected";
      });
    });

    _hubConnection.onreconnected((connectionId) {
      setState(() {
        _status = "Reconnected";
      });
    });

    _hubConnection.on("ReceiveMessage", (List<Object?>? message) async {
      if (message == null || message.isEmpty) return;

      String msg = message.first.toString().toLowerCase();
      setState(() {
        _status = "Message Received: $msg";
      });

      showToast(
        "Message: $msg",
        duration: const Duration(seconds: 3),
        position: ToastPosition.bottom,
      );

      // Sending a message to the server
      _hubConnection.invoke("Notification", args: [
        _hubConnection.connectionId,
        "$msg received from ${_hubConnection.connectionId}"
      ]).catchError((err) {
        print("Error while sending message: $err");
      });
    });
  }

  Future<void> _connectToSignal() async {
    setState(() {
      _status = "Connecting...";
    });

    try {
      await _hubConnection.start();
      setState(() {
        _status = "Connected ${_hubConnection.connectionId}";
      });
    } catch (e) {
      setState(() {
        _status = "Connection Failed: ${e.toString()}";
      });
    }
  }

  Future<void> _disconnectFromSignal() async {
    setState(() {
      _status = "Disconnecting...";
    });

    try {
      await _hubConnection.stop();
      setState(() {
        _status = "Disconnected";
      });
    } catch (e) {
      setState(() {
        _status = "Disconnection Failed: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/blue.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _device ?? "No Device",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _status,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        backgroundColor: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _connectToSignal,
                    child: const Text('Connect'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _disconnectFromSignal,
                    child: const Text('Disconnect'),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Logs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
