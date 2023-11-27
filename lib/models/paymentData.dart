// import 'dart:convert';

// List<PaymentDataModel> paymentDataModelFronJson(String str) =>
//     List<PaymentDataModel>.from(
//         json.decode(str).map((x) => PaymentDataModel.fromJson(x)));

// String paymentDataModelToSjon(List<PaymentDataModel> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
class PaymentOverlay {
  final int id;
  final String referenceId;
  final String transactionId;
  final String upiId;
  final String type;
  final String amount;
  final String currency;
  final String beneficiary;
  final bool isActive;
  final bool isPaid;
  final bool isSuspended;
  final String createdAt;
  final String updatedAt;
  final String accountId;
  final String upiUrl;

  PaymentOverlay({
    required this.id,
    required this.referenceId,
    required this.transactionId,
    required this.upiId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.beneficiary,
    required this.isActive,
    required this.isPaid,
    required this.isSuspended,
    required this.createdAt,
    required this.updatedAt,
    required this.accountId,
    required this.upiUrl,
  });

  factory PaymentOverlay.fromJson(Map<String, dynamic> json) {
    return PaymentOverlay(
      id: json['_id'],
      referenceId: json['reference_id'],
      transactionId: json['transaction_id'], 
      upiId: json['upi_id'],
      type: json['type'],
      amount: json['amount'],
      currency: json['currency'],
      beneficiary: json['beneficiary'],
      isActive: json['isActive'],
      isPaid: json['isPaid'],
      isSuspended: json['isSuspended'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      accountId: json['account_id'],
      upiUrl: json['upi_url'],
    );
  }
}
