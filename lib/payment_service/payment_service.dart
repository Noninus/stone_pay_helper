import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:stone_pay_helper/payment_service/payment_response.dart';

class PaymentService {
  final MethodChannel _messagesChannel;

  static StreamController<PaymentResponse> _controller =
      StreamController.broadcast();

  Stream get streamData => _controller.stream;

  PaymentService(this._messagesChannel);

  checkout() async {
    try {
      _messagesChannel.setMethodCallHandler((call) {
        switch (call.method) {
          case "checkoutCallback":
            var uri = Uri.parse(call.arguments);
            PaymentResponse paymentResponse = PaymentResponse(
                success:
                    uri.queryParameters['success'] == "true" ? true : false,
                message: uri.queryParameters['message'],
                reason: uri.queryParameters['reason'],
                responseCode: uri.queryParameters['response_code']);
            _controller.add(paymentResponse);
            break;
          default:
        }
      });
    } on PlatformException catch (e) {
      _controller.add(PaymentResponse(
          success: false,
          message: e.toString(),
          reason: "platError",
          responseCode: "9999"));
    }
    try {
      int amount = 001;
      bool editableAmount = false; //true, false
      int installmentCount; //número de 2 a 18
      String transactionType = "CREDIT"; //DEBIT, CREDIT, VOUCHER
      String installmentType; //MERCHANT, ISSUER, NONE
      int orderId;
      String returnScheme = "flutterdeeplinkdemo";

      await _messagesChannel.invokeMethod('sendDeeplink', {
        "amount": amount,
        "editableAmount": editableAmount,
        "installmentCount": installmentCount,
        "transactionType": transactionType,
        "installmentType": installmentType,
        "orderId": orderId,
        "returnScheme": returnScheme
      });
    } on PlatformException catch (e) {
      _controller.add(PaymentResponse(
          success: false,
          message: e.toString(),
          reason: "erro ao enviar deeplink",
          responseCode: "9998"));
    }
  }
}
