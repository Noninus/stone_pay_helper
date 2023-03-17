class PaymentRequest {
  int? amount;
  bool? editableAmount;
  int? installmentCount;
  String? transactionType;
  String? installmentType;
  int? orderId;
  String? returnScheme;

  PaymentRequest({
    this.amount,
    this.editableAmount,
    this.installmentCount,
    this.transactionType,
    this.installmentType,
    this.orderId,
    this.returnScheme,
  });

  PaymentRequest.fromJson(Map<String?, dynamic> json) {
    amount = json['amount'];
    editableAmount = json['editableAmount'];
    installmentCount = json['installmentCount'];
    transactionType = json['transactionType'];
    installmentType = json['installmentType'];
    orderId = json['orderId'];
    returnScheme = json['returnScheme'];
  }

  Map<String?, dynamic> toJson() {
    final Map<String?, dynamic> data = {};
    data['amount'] = amount;
    data['editableAmount'] = editableAmount;
    data['installmentCount'] = installmentCount;
    data['transactionType'] = transactionType;
    data['installmentType'] = installmentType;
    data['orderId'] = orderId;
    data['returnScheme'] = returnScheme;

    return data;
  }
}
