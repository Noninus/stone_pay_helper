import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:stone_pay_helper/stone_pay_helper.dart';
import 'package:stone_pay_helper_example/img_nota.dart';
import 'package:stone_pay_helper_example/img_string.dart';

class PrinterTestScreen extends StatefulWidget {
  @override
  _PrinterTestScreenState createState() => _PrinterTestScreenState();
}

class _PrinterTestScreenState extends State<PrinterTestScreen> {
  @override
  void initState() {
    super.initState();
    StonePayHelper.init();
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
                child: Text("print pre conta")),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
