import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

class HomeBar extends StatefulWidget {
  const HomeBar({super.key});

  @override
  _HomeBarState createState() => _HomeBarState();
}

class _HomeBarState extends State<HomeBar> {
  late HubConnection _hubConnection;
  String _status = "Initializing...";

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    initializeSignal();
  }

  Future<void> initializeSignal() async {
    const signalRUrl = 'https://automate20250117155727.azurewebsites.net/stock';

    _hubConnection = HubConnectionBuilder()
        .withUrl(
          signalRUrl,
          HttpConnectionOptions(
            transport: HttpTransportType.webSockets,
          ),
        )
        .withAutomaticReconnect()
        .build();



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

  static const List<Widget> _pages = <Widget>[
    Icon(
      Icons.call,
      size: 150,
    ),
    Icon(
      Icons.camera,
      size: 150,
    ),
    Icon(
      Icons.chat,
      size: 150,
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/blue.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          /***Center(
            child: _pages.elementAt(_selectedIndex),
          ),
          **/
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _status,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        backgroundColor: Colors.black54),
                  ),
                  const SizedBox(height: 10),
                  /**  const SizedBox(height: 10),
                Text(_status,
                    style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        backgroundColor: Colors.black54)),**/
                ],
              ),
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
