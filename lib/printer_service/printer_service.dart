import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class PrinterService {
  final MethodChannel _messagesChannel;

  PrinterService(this._messagesChannel);

  img.Image b64ToImage(String b64) {
    img.Image? image = img.decodeImage(base64.decode(b64));
    return img.copyResize(image!, width: 380);
  }

  String imageToBase64(img.Image image) {
    return base64Encode(img.encodeJpg(image));
  }

  printBase64(String base64) async {
    img.Image imagemResized = b64ToImage(base64);
    String imageBase64 = imageToBase64(imagemResized);
    print(imageBase64);
    await _messagesChannel.invokeMethod(
      'printBase64',
      {"base64": imageBase64},
    );
  }

  printText(String text) async {
    await _messagesChannel.invokeMethod(
      'printText',
      {"text": text},
    );
  }
}
