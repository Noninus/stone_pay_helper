import 'package:flutter/material.dart';
import 'package:stone_pay_helper_example/payment_test_screen.dart';
import 'package:stone_pay_helper_example/printer_test_screen.dart';

void main() {
  runApp(
    MaterialApp(
      home: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentTestScreen()));
                },
                child: Text("Ir para Payment")),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PrinterTestScreen()));
                },
                child: Text("Ir para Printer")),
          ],
        ),
      ),
    );
  }
}
