class PaymentResponse {
  bool success;
  String reason;
  String responseCode;
  String message;

  PaymentResponse({
    this.success,
    this.reason,
    this.responseCode,
    this.message,
  });

  PaymentResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    reason = json['reason'];
    responseCode = json['response_code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['reason'] = this.reason;
    data['response_code'] = this.responseCode;
    data['message'] = this.message;
    return data;
  }
}
