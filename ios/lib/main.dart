import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TerminalOutputScreen(),
    );
  }
}

class TerminalOutputScreen extends StatefulWidget {
  @override
  _TerminalOutputScreenState createState() => _TerminalOutputScreenState();
}

class _TerminalOutputScreenState extends State<TerminalOutputScreen> {
  List<String> logs = [];
  ScrollController _scrollController = ScrollController();
  late Timer _timer;
  final List<String> randomMessages = [
    "Initializing system...",
    "Fetching data...",
    "Connection established.",
    "Loading modules...",
    "Error: Unable to connect.",
    "Restarting services...",
    "User logged in.",
    "Updating database...",
    "Task completed successfully.",
    "Compiling assets...",
    "Network latency detected.",
    "Security scan in progress..."
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      _appendRandomText();
    });
  }

  void _appendRandomText() {
    setState(() {
      String newMessage =
          "${DateTime.now().toIso8601String()} - ${randomMessages[Random().nextInt(randomMessages.length)]}";
      logs.add(newMessage);
    });

    // Auto-scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String latestText = logs.isNotEmpty ? logs.last : "Waiting for updates...";

    return Scaffold(
      appBar: AppBar(title: Text("Live Terminal Output")),
      body: Column(
        children: [
          // Centered latest text
          Expanded(
            flex: 2,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20), // Added margin
                child: Text(
                  latestText,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          Divider(),
          // Scrollable terminal output with margins
          Expanded(
            flex: 3,
            child: Container(
             // color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 30), // Margin for list
              child: ListView.builder(
                controller: _scrollController,
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 1), // Margin for items
                    child: Text(
                      logs[index],
                      style: TextStyle(color: Colors.green, fontFamily: "monospace"),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
