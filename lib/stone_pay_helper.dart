import 'dart:async';

import 'package:flutter/services.dart';
import 'package:stone_pay_helper/payment_service/payment_request.dart';
import 'package:stone_pay_helper/payment_service/payment_response.dart';
import 'package:stone_pay_helper/payment_service/payment_service.dart';
import 'package:stone_pay_helper/printer_service/printer_service.dart';

class StonePayHelper {
  static const MethodChannel _channel = const MethodChannel('stone_pay_helper');
  static late PaymentService _paymentService;
  static late PrinterService _printerService;

  static init() async {
    await _channel.invokeMethod('initStone'); // Método inicial initStone.
    _paymentService = PaymentService(_channel);
    _printerService = PrinterService(_channel);
  }

  /// Enable or disable Stone SDK debug mode for complete logs
  static Future<bool> enableDebugMode({bool enable = true}) async {
    try {
      await _channel.invokeMethod('enableDebugMode', {'enable': enable});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sends a [PaymentRequest] to Lio and waits until the payment is finished or canceled to execute [callback]
  static checkout(PaymentRequest paymentRequest) {
    _paymentService.checkout(paymentRequest);
  }

  /// Stream do checkout
  static Stream<PaymentResponse> get checkoutStreamListen =>
      _paymentService.streamData;

  /// Sends base64 to print
  static printBase64(String base64) {
    _printerService.printBase64(base64);
  }

  /// Sends text to print
  static printText(String text) {
    _printerService.printText(text);
  }

  /// Stream do checkout
  static Stream<String> get printerStreamListen => _printerService.streamData;

  /// Returns the establishment code from InfoManager of Lio
  static Future<bool> get isStone async {
    bool isStone = false;
    try {
      String resStone = await _channel.invokeMethod('isStone');
      if (resStone.toUpperCase() == "MOBILE") {
        isStone = false;
      } else {
        isStone = true;
      }
    } catch (e) {
      isStone = false;
    }
    return isStone;
  }

  /// Returns the ec
  static Future<String> get ec async {
    String ec;
    try {
      ec = await _channel.invokeMethod('getEc');
    } catch (e) {
      ec = "error";
    }
    return ec;
  }

  /// Sends deeplink printer request with stylized content and returns the print result
  /// Returns: Print status like "SUCCESS", "PRINTER_OUT_OF_PAPER", etc.
  static Future<String> sendDeepLinkPrinter({
    required String printingData,
    String? returnScheme,
    bool showFeedbackScreen = false,
  }) async {
    try {
      final String result = await _channel.invokeMethod('sendDeepLinkPrinter', {
        'printingData': printingData,
        'returnScheme': returnScheme,
        'showFeedbackScreen': showFeedbackScreen,
      });
      return result;
    } catch (e) {
      return "ERROR: $e";
    }
  }

}
