import 'dart:async';

import 'package:flutter/services.dart';
import 'package:stone_pay_helper/payment_service/payment_response.dart';
import 'package:stone_pay_helper/payment_service/payment_service.dart';

class StonePayHelper {
  static const MethodChannel _channel = const MethodChannel('stone_pay_helper');
  static PaymentService _paymentService;

  static init() {
    _paymentService = PaymentService(_channel);
  }

  /// Sends a [CheckoutRequest] to Lio and waits until the payment is finished or canceled to execute [callback]
  static checkout() {
    _paymentService.checkout();
  }

  /// Stream do checkout
  static Stream<PaymentResponse> get checkoutStreamListen =>
      _paymentService.streamData;
}
