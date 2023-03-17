import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:stone_pay_helper/payment_service/payment_request.dart';
import 'package:stone_pay_helper/payment_service/payment_response.dart';
import 'package:stone_pay_helper/stone_pay_helper.dart';

class PaymentTestScreen extends StatefulWidget {
  @override
  _PaymentTestScreenState createState() => _PaymentTestScreenState();
}

class _PaymentTestScreenState extends State<PaymentTestScreen> {
  String _platformVersion = 'Unknown';

  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    subscription = StonePayHelper.checkoutStreamListen
        .listen((PaymentResponse paymentResponse) {
      print("===== CALLBACK ${paymentResponse.success} =======");
      SchedulerBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _platformVersion = paymentResponse.message;
        });
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkout() async {
    PaymentRequest paymentRequest = PaymentRequest(
      amount: 100,
      editableAmount: false,
      installmentCount: null,
      transactionType: "CREDIT",
      installmentType: null,
      orderId: null,
      returnScheme: "flutterdeeplinkdemo",
    );

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      await StonePayHelper.checkout(paymentRequest);
    } on PlatformException {
      print('Failed to get platform version.');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
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
          ],
        ),
      ),
    );
  }
}
