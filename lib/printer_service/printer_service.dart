import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class PrinterService {
  final MethodChannel _messagesChannel;

  static StreamController<String> _controller = StreamController.broadcast();

  Stream<String> get streamData => _controller.stream;

  PrinterService(this._messagesChannel);

  img.Image b64ToImage(String b64) {
    img.Image? image = img.decodeImage(base64.decode(b64));
    if (image!.width > 385) {
      return img.copyResize(image, width: 380);
    } else {
      return image;
    }
  }

  String imageToBase64(img.Image image) {
    return base64Encode(img.encodeJpg(image));
  }

  listenCallback() {
    try {
      _messagesChannel.setMethodCallHandler((call) async {
        switch (call.method) {
          case "printerCallback":
            _controller.add(call.arguments);
            break;
          default:
        }
      });
    } on PlatformException catch (e) {
      _controller.add("error");
    }
  }

  printBase64(String base64) async {
    img.Image imagemResized = b64ToImage(base64);
    String imageBase64 = imageToBase64(imagemResized);
    await listenCallback();
    await _messagesChannel.invokeMethod(
      'printBase64',
      {"base64": imageBase64},
    );
  }

  printText(String text) async {
    await listenCallback();
    await _messagesChannel.invokeMethod(
      'printText',
      {"text": text},
    );
  }
}
