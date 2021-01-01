import 'package:AriesFlutterMobileAgent_example/screens/connection_screen.dart';
import 'package:AriesFlutterMobileAgent_example/screens/create_wallet_screen.dart';
import 'package:AriesFlutterMobileAgent_example/screens/qrcode_screen.dart';
import 'package:flutter/material.dart';
import 'package:AriesFlutterMobileAgent/AriesAgent.dart';

import 'screens/connect_mediator_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AriesFlutterMobileAgent.init();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedIn = false;

  void isValidUser() async {
    var userData = await DBServices.getWalletData();
    if (userData != null) {
      setState(() {
        loggedIn = true;
      });
    }
  }

  void connectSocket() async {
    try {
      var sdkDB = await DBServices.getWalletData();
      if (sdkDB != null) {
        AriesFlutterMobileAgent.socketInit();
      }
    } catch (error) {
      print('Oops! Something went wrong. Please try again later. $error');
    }
  }

  @override
  void initState() {
    super.initState();
    connectSocket();
    isValidUser();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Agent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: loggedIn ? ConnectionScreen() : CreateWalletScreen(),
      routes: {
        ConnectMediatorScreen.routeName: (ctx) => ConnectMediatorScreen(),
        ConnectionScreen.routeName: (ctx) => ConnectionScreen(),
        QRcodeScreen.routeName: (ctx) => QRcodeScreen(),
      },
    );
  }
}
