import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:stone_pay_helper/stone_pay_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String deeplinkResult = "";

  static const platformMethodChannel =
      const MethodChannel("mainDeeplinkChannel");

  Future<Null> _sendDeeplink() async {
    String _message = "";
    try {
      int amount = 001;
      bool editableAmount = false; //true, false
      int installmentCount; //número de 2 a 18
      String transactionType = "CREDIT"; //DEBIT, CREDIT, VOUCHER
      String installmentType; //MERCHANT, ISSUER, NONE
      int orderId;
      String returnScheme = "flutterdeeplinkdemo";

      await platformMethodChannel.invokeMethod('sendDeeplink', {
        "amount": amount,
        "editableAmount": editableAmount,
        "installmentCount": installmentCount,
        "transactionType": transactionType,
        "installmentType": installmentType,
        "orderId": orderId,
        "returnScheme": returnScheme
      });
    } on PlatformException catch (e) {
      _message = "Erro ao enviar deeplink: ${e.message}.";
    }
    setState(() {
      deeplinkResult = _message;
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await StonePayHelper.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkout() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await StonePayHelper.checkout;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            ElevatedButton(
                onPressed: () {
                  checkout();
                },
                child: Text("checkout")),
            SizedBox(
              height: 10,
            ),
            Text("$deeplinkResult"),
            ElevatedButton(
                onPressed: () {
                  _sendDeeplink();
                },
                child: Text("_sendDeeplink")),
          ],
        ),
      ),
    );
  }
}
