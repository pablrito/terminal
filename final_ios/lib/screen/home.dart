import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HubConnection _hubConnection;
  bool _isConnected = false; // Track connection status
  String _status = "Initializing...";

  @override
  void initState() {
    super.initState();
    initializeSignal();
  }

  Future<void> initializeSignal() async {
    const signalRUrl =
        'https://automate20250117155727.azurewebsites.net/terminal';

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
        _isConnected = false;
      });
    });

    _hubConnection.onreconnected((connectionId) {
      setState(() {
        _status = "Reconnected";
        _isConnected = true;
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? previousConnectionId = prefs.getString("connectionId");

      await _hubConnection.start();

      String? newConnectionId = _hubConnection.connectionId;

      if (newConnectionId != null) {
        await prefs.setString("connectionId", newConnectionId);
      }

      setState(() {
        _status = "Connected ${_hubConnection.connectionId}";
        _isConnected = true;
      });

      if (previousConnectionId != null) {
        print(
            "should we call previos $previousConnectionId newconnection $newConnectionId");
        //  await _hubConnection.invoke("Reconnect", args: [previousConnectionId, newConnectionId]);
      }
    } catch (e) {
      setState(() {
        _status = "Connection Failed: ${e.toString()}";
        _isConnected = false;
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
        _isConnected = false;
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
                  OutlinedButton(
                    onPressed: _isConnected ? null : _connectToSignal,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: Colors.green, width: 2), // Green border
                      foregroundColor : Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Connect'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _isConnected ? _disconnectFromSignal : null,
                    style: OutlinedButton.styleFrom(
                      side:
                          BorderSide(color: Colors.green, width: 2), 
                       foregroundColor : Colors.white,
                     //  backgroundColor: Colors.red, // Green when enabled
         
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
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
