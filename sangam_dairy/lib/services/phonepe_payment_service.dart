import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PhonePePaymentService {
  // ------------------------------------------------------------
  // SANGAM DAIRY TEST UPI ID
  // ------------------------------------------------------------
  static const String merchantUpiId = '9390736087-2@ybl';

  static const String merchantName = 'Sangam Dairy';

  // ------------------------------------------------------------
  // START PHONEPE PAYMENT
  // ------------------------------------------------------------
  static Future<bool> startPayment({
    required double amount,
    required String orderReference,
  }) async {
    final String formattedAmount = amount.toStringAsFixed(2);

    final Uri phonePeUri = Uri(
      scheme: 'phonepe',
      host: 'pay',
      queryParameters: {
        // Receiver UPI ID
        'pa': merchantUpiId,

        // Receiver name
        'pn': merchantName,

        // Payment amount
        'am': formattedAmount,

        // Currency
        'cu': 'INR',

        // Transaction note
        'tn': 'Sangam Dairy Order $orderReference',

        // Transaction reference
        'tr': orderReference,
      },
    );

    // Web is not supported for PhonePe app launch.
    if (kIsWeb) {
      return false;
    }

    try {
      final bool launched = await launchUrl(
        phonePeUri,
        mode: LaunchMode.externalApplication,
      );

      return launched;
    } catch (_) {
      return false;
    }
  }
}
