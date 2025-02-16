import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:device_info_plus/device_info_plus.dart';
//import 'package:url_launcher/url_launcher.dart';

Future<String?> getIOSUUID() async {
  final deviceInfo = DeviceInfoPlugin();
  IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  return iosInfo.identifierForVendor;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _TerminalOutputScreenState createState() => _TerminalOutputScreenState();
}

class _TerminalOutputScreenState extends State<HomeScreen> {
  late HubConnection _hubConnection;
  String? _device = "";
  String _status = "Initializing...";
  bool _isCalling = false; // Track call status

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

      if (msg == "call") {
        _makePhoneCall("222");
      } else if (msg == "hangup") {
        _hangUpCall();
      } else if (msg == "answer") {
        _answerCall();
      }
    });

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

  // ✅ Make a Call
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri.parse("tel:$phoneNumber");
  /**   if (await canLaunchUrl(url)) {
      await launchUrl(url);
      setState(() {
        _isCalling = true;
        _status = "Calling $phoneNumber...";
      });
    } else {
      setState(() {
        _status = "Failed to Call";
      });
    }**/
  }

  // ✅ Answer Call (Dummy logic for now)
  void _answerCall() {
    if (!_isCalling) {
      setState(() {
        _status = "No Incoming Call";
      });
      return;
    }
    setState(() {
      _status = "Call Answered!";
    });
  }

  // ✅ Hang Up Call (Dummy logic for now)
  void _hangUpCall() {
    if (!_isCalling) {
      setState(() {
        _status = "No Active Call";
      });
      return;
    }
    setState(() {
      _isCalling = false;
      _status = "Call Ended";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/4.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Centered Top Label with Status
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Automate",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  Text(
                    _device!,
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

          // Centered Buttons
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
