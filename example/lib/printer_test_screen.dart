import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:stone_pay_helper/stone_pay_helper.dart';
import 'package:stone_pay_helper_example/img_nota.dart';
import 'package:stone_pay_helper_example/img_string.dart';
import 'package:stone_pay_helper_example/img_string_ja_convertida.dart';

class PrinterTestScreen extends StatefulWidget {
  @override
  _PrinterTestScreenState createState() => _PrinterTestScreenState();
}

class _PrinterTestScreenState extends State<PrinterTestScreen> {
  StreamSubscription subscription;
  bool successPrint = true;
  final globalScaffoldKey = GlobalKey<ScaffoldMessengerState>();
  @override
  void initState() {
    super.initState();
    subscription =
        StonePayHelper.printerStreamListen.listen((String printerCallback) {
      print("===== CALLBACK $printerCallback =======");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (printerCallback.contains("error")) {
          if (printerCallback.contains("PRINTER_OUT_OF_PAPER_ERROR")) {
            print("sem papel");
          }
          setState(() {
            print("erro");
            successPrint = false;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  Future<void> printBase64() async {
    try {
      await StonePayHelper.printBase64(imgNota);
    } on PlatformException {
      print('Failed to get platform version.');
    }
    if (!mounted) return;
  }

  Future<void> printBase64PreConta() async {
    try {
      await StonePayHelper.printBase64(imgString);
    } on PlatformException {
      print('Failed to get platform version.');
    }
    if (!mounted) return;
  }

  Future<void> printBase64JaConvertidaPreConta() async {
    try {
      await StonePayHelper.printBase64(imgJaConvertida380);
    } on PlatformException {
      print('Failed to get platform version.');
    }
    if (!mounted) return;
  }

  Future<void> printText() async {
    try {
      await StonePayHelper.printText(
          "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum");
    } on PlatformException {
      print('Failed to get platform version.');
    }
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: globalScaffoldKey,
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  printBase64();
                },
                child: Text("printBase64")),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  printText();
                },
                child: Text("printText")),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  printBase64PreConta();
                },
                child: Text("print pre conta convertida por flutter")),
            ElevatedButton(
                onPressed: () {
                  printBase64JaConvertidaPreConta();
                },
                child: Text("printBase64JaConvertidaPreContaSemFlutter")),
            SizedBox(
              height: 10,
            ),
            successPrint
                ? Icon(Icons.check_circle_outline, color: Colors.green)
                : Icon(Icons.error, color: Colors.red)
          ],
        ),
      ),
    );
  }
}
