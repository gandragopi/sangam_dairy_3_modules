import 'package:android_intent_plus/android_intent.dart';

class GooglePayPaymentService {
  // Sangam Dairy UPI ID
  static const String upiId = 'gandragopigandra123-1@okhdfcbank';

  // Name shown inside Google Pay
  static const String payeeName = 'Sangam Dairy';

  // Currency
  static const String currency = 'INR';

  /// Opens Google Pay directly with a UPI payment request.
  ///
  /// IMPORTANT:
  /// Opening Google Pay does NOT confirm that payment was successful.
  /// Payment success must be verified through a proper payment gateway/
  /// backend before treating an order as paid.
  static Future<bool> startPayment({
    required double amount,
    required String orderReference,
  }) async {
    try {
      final String amountString = amount.toStringAsFixed(2);

      final String transactionNote =
          'Sangam Dairy Order $orderReference';

      final String upiUrl =
          'upi://pay'
          '?pa=${Uri.encodeComponent(upiId)}'
          '&pn=${Uri.encodeComponent(payeeName)}'
          '&am=${Uri.encodeComponent(amountString)}'
          '&cu=$currency'
          '&tr=${Uri.encodeComponent(orderReference)}'
          '&tn=${Uri.encodeComponent(transactionNote)}';

      final AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: upiUrl,
        package: 'com.google.android.apps.nbu.paisa.user',
      );

      await intent.launch();

      return true;
    } catch (e) {
      return false;
    }
  }
}
