import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';


Future<String?> getIOSUUID() async {
  final deviceInfo = DeviceInfoPlugin();
  IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  return iosInfo.identifierForVendor;
}

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
  void initState()  {
    super.initState();
    initializeSignal();

    
    
  }

  Future<void> initializeSignal() async {
    const signalRUrl =
        'https://automate20250117155727.azurewebsites.net/terminal';

        try {
      String? device = await getIOSUUID();
      setState(() {
        _device = device ?? "Unknown Device";
      });
    } catch (e) {
      setState(() {
        _status = "Error: ${e.toString()}";
      });
    }

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

Fluttertoast.showToast(
    msg: "New Message: $msg",
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.black54,
    textColor: Colors.white,
    fontSize: 16.0,
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

  // ✅ Start Connection
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

  // ✅ Stop Connection
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
    return Scaffold(
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
                    _device ?? "No Device", // <-- Fixed null handling
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
    );
  }
}
