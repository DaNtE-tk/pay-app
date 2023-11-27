import 'package:easy_upi_payment/easy_upi_payment.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app_storage.dart';

class PaymentStateNotifier extends StateNotifier<PaymentState> {
  PaymentStateNotifier(this.ref) : super(PaymentState.initial);

  TransactionDetailModel? transactionDetailModel;

  final Ref ref;

  Future<void> startPayment(EasyUpiPaymentModel model) async {
    state = PaymentState.loading;
    try {
      savePaymentData(model);
      final res = await EasyUpiPaymentPlatform.instance.startPayment(model);
      if (res != null) {
        transactionDetailModel = res;
        state = PaymentState.success;
      } else {
        state = PaymentState.error;
      }
    } on EasyUpiPaymentException {
      state = PaymentState.error;
    }
  }

  void savePaymentData(EasyUpiPaymentModel model) {
    ref.read(appStorageProvider)
      ..putName(model.payeeName)
      ..putUpiId(model.payeeVpa)
      ..putAmount(model.amount.toString());

    if (model.description != null) {
      ref.read(appStorageProvider).putDescription(model.description!);
    }
  }
}

final paymentStateProvider =
    StateNotifierProvider.autoDispose<PaymentStateNotifier, PaymentState>(
  (ref) {
    return PaymentStateNotifier(ref);
  },
);

enum PaymentState { initial, loading, success, error }
