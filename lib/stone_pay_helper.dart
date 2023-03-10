import 'dart:async';

import 'package:flutter/services.dart';

class StonePayHelper {
  static const MethodChannel _channel = const MethodChannel('stone_pay_helper');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get checkout async {
    String _message = "";
    try {
      int amount = 001;
      bool editableAmount = false; //true, false
      int installmentCount; //número de 2 a 18
      String transactionType = "CREDIT"; //DEBIT, CREDIT, VOUCHER
      String installmentType; //MERCHANT, ISSUER, NONE
      int orderId;
      String returnScheme = "flutterdeeplinkdemo";

      await _channel.invokeMethod('sendDeeplink', {
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
    return _message;
  }
}
