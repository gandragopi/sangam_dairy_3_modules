import 'package:flutter/material.dart';

import '../../services/order_api_service.dart';
import '../../services/payment_api_service.dart';
import '../orders/order_success_screen.dart';

class NetBankingScreen extends StatefulWidget {
const NetBankingScreen({
super.key,
required this.amount,
required this.customerName,
required this.mobile,
required this.address,
required this.city,
required this.pincode,
required this.cartItems,
required this.subtotal,
required this.deliveryCharge,
});

final double amount;

final String customerName;
final String mobile;
final String address;
final String city;
final String pincode;

final List<Map<String, dynamic>> cartItems;
final double subtotal;
final double deliveryCharge;

@override
State<NetBankingScreen> createState() => _NetBankingScreenState();
}

class _NetBankingScreenState extends State<NetBankingScreen> {
// ============================================================
// COLORS
// ============================================================

static const Color primaryGreen = Color(0xFF087A35);
static const Color darkGreen = Color(0xFF173B20);
static const Color lightGreen = Color(0xFFE8F5E9);
static const Color pageBackground = Color(0xFFF6F9F6);
static const Color orange = Color(0xFFFFA916);
static const Color textGrey = Color(0xFF69736B);

// ============================================================
// BANKS
// ============================================================

final List<String> _banks = [
'State Bank of India',
'HDFC Bank',
'ICICI Bank',
'Axis Bank',
'Kotak Mahindra Bank',
'IndusInd Bank',
];

String? _selectedBank;

bool _isProcessing = false;

// Keep these controllers alive until the Net Banking screen is disposed.
// Disposing them immediately after Navigator.pop() can trigger Flutter's
// _dependents.isEmpty assertion while the dialog is still being removed.
final TextEditingController _customerIdController =
TextEditingController();
final TextEditingController _passwordController =
TextEditingController();

@override
void dispose() {
_customerIdController.dispose();
_passwordController.dispose();
super.dispose();
}

// ============================================================
// FORMAT PRICE
// ============================================================

String _formatPrice(double value) {
return '₹${value.toStringAsFixed(0)}';
}

// ============================================================
// CONTINUE
// ============================================================

Future<void> _continueToBanking() async {
if (_selectedBank == null) {
_showMessage('Please select your bank.');
return;
}

if (widget.amount <= 0) {
_showMessage('Invalid payment amount.');
return;
}

await _showDemoBankLogin();
}

// ============================================================
// DEMO BANK LOGIN
// ============================================================

Future<void> _showDemoBankLogin() async {
_customerIdController.clear();
_passwordController.clear();

bool obscurePassword = true;

final bool? loginSuccess = await showDialog<bool>(
context: context,
barrierDismissible: false,
builder: (dialogContext) {
return StatefulBuilder(
builder: (context, setDialogState) {
return AlertDialog(
backgroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(24),
),
title: Row(
children: [
Container(
width: 46,
height: 46,
decoration: BoxDecoration(
color: lightGreen,
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.account_balance_rounded,
color: primaryGreen,
size: 26,
),
),
const SizedBox(width: 12),
Expanded(
child: Text(
_selectedBank ?? 'Bank',
style: const TextStyle(
color: darkGreen,
fontSize: 16,
fontWeight: FontWeight.w900,
),
),
),
],
),
content: SingleChildScrollView(
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: double.infinity,
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(
color: const Color(0xFFFFF8E7),
borderRadius: BorderRadius.circular(12),
border: Border.all(
color: const Color(0xFFFFE0A3),
),
),
child: const Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
Icons.info_outline_rounded,
color: Colors.orange,
size: 20,
),
SizedBox(width: 8),
Expanded(
child: Text(
'Demo banking screen. Do not enter real bank credentials.',
style: TextStyle(
color: Colors.black87,
fontSize: 11,
height: 1.4,
fontWeight: FontWeight.w600,
),
),
),
],
),
),

const SizedBox(height: 18),

const Align(
alignment: Alignment.centerLeft,
child: Text(
'Customer ID',
style: TextStyle(
color: darkGreen,
fontSize: 12,
fontWeight: FontWeight.w800,
),
),
),

const SizedBox(height: 7),

TextField(
controller: _customerIdController,
textInputAction: TextInputAction.next,
decoration: InputDecoration(
hintText: 'Enter demo customer ID',
prefixIcon: const Icon(
Icons.person_outline_rounded,
color: primaryGreen,
),
filled: true,
fillColor: pageBackground,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 14),

const Align(
alignment: Alignment.centerLeft,
child: Text(
'Password',
style: TextStyle(
color: darkGreen,
fontSize: 12,
fontWeight: FontWeight.w800,
),
),
),

const SizedBox(height: 7),

TextField(
controller: _passwordController,
obscureText: obscurePassword,
textInputAction: TextInputAction.done,
decoration: InputDecoration(
hintText: 'Enter demo password',
prefixIcon: const Icon(
Icons.lock_outline_rounded,
color: primaryGreen,
),
suffixIcon: IconButton(
onPressed: () {
setDialogState(() {
obscurePassword = !obscurePassword;
});
},
icon: Icon(
obscurePassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
color: textGrey,
),
),
filled: true,
fillColor: pageBackground,
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(14),
borderSide: BorderSide.none,
),
),
),

const SizedBox(height: 12),

const Text(
'Demo Customer ID: demo\n'
'Demo Password: 1234',
textAlign: TextAlign.center,
style: TextStyle(
color: textGrey,
fontSize: 11,
height: 1.5,
fontWeight: FontWeight.w600,
),
),
],
),
),
actionsPadding: const EdgeInsets.fromLTRB(
18,
0,
18,
18,
),
actions: [
Row(
children: [
Expanded(
child: OutlinedButton(
onPressed: () {
Navigator.pop(dialogContext, false);
},
style: OutlinedButton.styleFrom(
foregroundColor: darkGreen,
side: const BorderSide(
color: Color(0xFFD7E1D9),
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
padding: const EdgeInsets.symmetric(
vertical: 14,
),
),
child: const Text(
'CANCEL',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w900,
),
),
),
),
const SizedBox(width: 10),
Expanded(
child: ElevatedButton(
onPressed: () {
  if (_customerIdController.text.trim() == 'demo' &&
      _passwordController.text == '1234') {
Navigator.pop(dialogContext, true);
} else {
ScaffoldMessenger.of(dialogContext)
    .showSnackBar(
const SnackBar(
backgroundColor: Colors.red,
content: Text(
'Use demo / 1234 for testing.',
),
),
);
}
},
style: ElevatedButton.styleFrom(
backgroundColor: primaryGreen,
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
padding: const EdgeInsets.symmetric(
vertical: 14,
),
),
child: const Text(
'LOGIN',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w900,
),
),
),
),
],
),
],
);
},
);
},
);

// Do not dispose the TextEditingControllers here.
// The dialog may still be completing its removal in the current frame.
// They are disposed safely in the State.dispose() method instead.

await Future<void>.delayed(const Duration(milliseconds: 100));

if (loginSuccess != true || !mounted) {
return;
}

await _showPaymentConfirmation();
}

// ============================================================
// PAYMENT CONFIRMATION
// ============================================================

Future<void> _showPaymentConfirmation() async {
final bool? confirmed = await showDialog<bool>(
context: context,
barrierDismissible: false,
builder: (dialogContext) {
return AlertDialog(
backgroundColor: Colors.white,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(24),
),
title: const Text(
'Confirm Payment',
style: TextStyle(
color: darkGreen,
fontSize: 20,
fontWeight: FontWeight.w900,
),
),
content: Column(
mainAxisSize: MainAxisSize.min,
children: [
Container(
width: 70,
height: 70,
decoration: BoxDecoration(
color: lightGreen,
shape: BoxShape.circle,
),
child: const Icon(
Icons.account_balance_rounded,
color: primaryGreen,
size: 34,
),
),

const SizedBox(height: 18),

Text(
_selectedBank ?? '',
textAlign: TextAlign.center,
style: const TextStyle(
color: darkGreen,
fontSize: 15,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 10),

Text(
_formatPrice(widget.amount),
style: const TextStyle(
color: primaryGreen,
fontSize: 30,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 10),

const Text(
'Do you want to confirm this demo payment?',
textAlign: TextAlign.center,
style: TextStyle(
color: textGrey,
fontSize: 12,
height: 1.4,
),
),
],
),
actionsPadding: const EdgeInsets.fromLTRB(
18,
0,
18,
18,
),
actions: [
Row(
children: [
Expanded(
child: OutlinedButton(
onPressed: () {
Navigator.pop(dialogContext, false);
},
style: OutlinedButton.styleFrom(
foregroundColor: darkGreen,
side: const BorderSide(
color: Color(0xFFD7E1D9),
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
padding: const EdgeInsets.symmetric(
vertical: 14,
),
),
child: const Text(
'CANCEL',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w900,
),
),
),
),
const SizedBox(width: 10),
Expanded(
child: ElevatedButton(
onPressed: () {
Navigator.pop(dialogContext, true);
},
style: ElevatedButton.styleFrom(
backgroundColor: primaryGreen,
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
padding: const EdgeInsets.symmetric(
vertical: 14,
),
),
child: const Text(
'CONFIRM',
style: TextStyle(
fontSize: 12,
fontWeight: FontWeight.w900,
),
),
),
),
],
),
],
);
},
);

// Allow the confirmation dialog route to finish closing before
// starting the payment/order flow.
await Future<void>.delayed(Duration.zero);

if (confirmed != true || !mounted) {
return;
}

await _processPayment();
}

// ============================================================
// PROCESS PAYMENT
// ============================================================

Future<void> _processPayment() async {
if (_isProcessing) {
return;
}

if (widget.cartItems.isEmpty) {
_showMessage('Your cart is empty.');
return;
}

setState(() {
_isProcessing = true;
});

final String timestamp =
DateTime.now().millisecondsSinceEpoch.toString();

final String paymentReference = 'NETBANK_$timestamp';
final String transactionId = 'NB_TXN_$timestamp';

try {
// ----------------------------------------------------------
// STEP 1: CREATE PENDING PAYMENT
// ----------------------------------------------------------

await PaymentApiService.createPayment(
orderKey: 'guest_cart',
paymentReference: paymentReference,
amount: widget.amount,
paymentMethod: 'Net Banking',
);

if (!mounted) {
return;
}

_showMessage('Processing bank payment...');

// Small demo delay to simulate bank processing.
await Future<void>.delayed(
const Duration(seconds: 2),
);

if (!mounted) {
return;
}

// ----------------------------------------------------------
// STEP 2: MARK PAYMENT SUCCESS
// ----------------------------------------------------------

await PaymentApiService.markPaymentSuccess(
paymentReference: paymentReference,
transactionId: transactionId,
);

if (!mounted) {
return;
}

_showMessage('Payment successful. Placing order...');

// ----------------------------------------------------------
// STEP 3: CREATE ORDER
// ----------------------------------------------------------

final Map<String, dynamic> order =
await OrderApiService.createOrder(
customerName: widget.customerName,
mobile: widget.mobile,
address: widget.address,
city: widget.city,
pincode: widget.pincode,
paymentMethod: 'Net Banking',
);

final String orderId =
order['id']?.toString() ?? 'SANGAM-ORDER';

if (!mounted) {
return;
}

// Reset the old screen BEFORE replacing its route.
setState(() {
_isProcessing = false;
});

// Let the current route finish this frame before replacement.
await Future<void>.delayed(Duration.zero);

if (!mounted) {
return;
}

// ----------------------------------------------------------
// STEP 4: ORDER SUCCESS
// ----------------------------------------------------------

Navigator.pushReplacement(
context,
MaterialPageRoute(
builder: (_) => OrderSuccessScreen(
orderId: orderId,
totalAmount: widget.amount,
paymentMethod: 'Net Banking',
customerName: widget.customerName,
mobile: widget.mobile,
address: widget.address,
city: widget.city,
pincode: widget.pincode,
items: widget.cartItems,
subtotal: widget.subtotal,
deliveryCharge: widget.deliveryCharge,
),
),
);
} catch (e) {
if (!mounted) {
return;
}

setState(() {
_isProcessing = false;
});

_showMessage(
'Payment or order failed. Please try again.',
);
}
}

// ============================================================
// MESSAGE
// ============================================================

void _showMessage(String message) {
ScaffoldMessenger.of(context).hideCurrentSnackBar();

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
behavior: SnackBarBehavior.floating,
backgroundColor: darkGreen,
content: Text(
message,
style: const TextStyle(
color: Colors.white,
fontWeight: FontWeight.w700,
),
),
),
);
}

// ============================================================
// BANK CARD
// ============================================================

Widget _bankCard(String bank) {
final bool selected = _selectedBank == bank;

return GestureDetector(
onTap: _isProcessing
? null
    : () {
setState(() {
_selectedBank = bank;
});
},
child: AnimatedContainer(
duration: const Duration(milliseconds: 180),
margin: const EdgeInsets.only(bottom: 12),
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: selected ? lightGreen : Colors.white,
borderRadius: BorderRadius.circular(17),
border: Border.all(
color: selected
? primaryGreen
    : const Color(0xFFE0E8E2),
width: selected ? 1.5 : 1,
),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.04),
blurRadius: 8,
offset: const Offset(0, 3),
),
],
),
child: Row(
children: [
Container(
width: 50,
height: 50,
decoration: BoxDecoration(
color: selected ? Colors.white : lightGreen,
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.account_balance_rounded,
color: primaryGreen,
size: 27,
),
),

const SizedBox(width: 13),

Expanded(
child: Text(
bank,
style: const TextStyle(
color: darkGreen,
fontSize: 14,
fontWeight: FontWeight.w800,
),
),
),

const SizedBox(width: 10),

Container(
width: 23,
height: 23,
decoration: BoxDecoration(
shape: BoxShape.circle,
border: Border.all(
color: selected
? primaryGreen
    : Colors.black26,
width: 2,
),
),
child: selected
? Container(
margin: const EdgeInsets.all(4),
decoration: const BoxDecoration(
color: primaryGreen,
shape: BoxShape.circle,
),
)
    : null,
),
],
),
),
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: pageBackground,

appBar: AppBar(
backgroundColor: primaryGreen,
foregroundColor: Colors.white,
elevation: 0,
titleSpacing: 18,
title: Row(
children: [
Container(
width: 42,
height: 42,
padding: const EdgeInsets.all(5),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
),
child: Image.asset(
'assets/images/sangam_logo.png',
fit: BoxFit.contain,
errorBuilder: (
context,
error,
stackTrace,
) {
return const Icon(
Icons.local_drink_rounded,
color: primaryGreen,
);
},
),
),

const SizedBox(width: 11),

const Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Sangam Dairy',
style: TextStyle(
color: Colors.white,
fontSize: 18,
fontWeight: FontWeight.w900,
),
),
Text(
'Net Banking',
style: TextStyle(
color: Colors.white70,
fontSize: 11,
fontWeight: FontWeight.w500,
),
),
],
),
],
),
),

body: Stack(
children: [
// ======================================================
// CONTENT
// ======================================================

SafeArea(
child: SingleChildScrollView(
physics: const BouncingScrollPhysics(),
padding: const EdgeInsets.fromLTRB(
16,
18,
16,
30,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'Net Banking',
style: TextStyle(
color: darkGreen,
fontSize: 24,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 6),

const Text(
'Select your bank to continue with payment.',
style: TextStyle(
color: textGrey,
fontSize: 12,
fontWeight: FontWeight.w500,
),
),

const SizedBox(height: 20),

// ==================================================
// AMOUNT CARD
// ==================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(18),
decoration: BoxDecoration(
color: darkGreen,
borderRadius: BorderRadius.circular(22),
),
child: Row(
children: [
Container(
width: 50,
height: 50,
decoration: BoxDecoration(
color: Colors.white.withValues(
alpha: 0.12,
),
borderRadius: BorderRadius.circular(14),
),
child: const Icon(
Icons.account_balance_wallet_rounded,
color: Colors.white,
size: 27,
),
),

const SizedBox(width: 14),

const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'Amount to Pay',
style: TextStyle(
color: Colors.white70,
fontSize: 11,
fontWeight: FontWeight.w600,
),
),
SizedBox(height: 4),
Text(
'Sangam Dairy Order',
style: TextStyle(
color: Colors.white,
fontSize: 14,
fontWeight: FontWeight.w800,
),
),
],
),
),

Text(
_formatPrice(widget.amount),
style: const TextStyle(
color: Colors.white,
fontSize: 22,
fontWeight: FontWeight.w900,
),
),
],
),
),

const SizedBox(height: 22),

const Text(
'Select Your Bank',
style: TextStyle(
color: darkGreen,
fontSize: 18,
fontWeight: FontWeight.w900,
),
),

const SizedBox(height: 11),

// ==================================================
// BANK LIST
// ==================================================

RadioGroup<String>(
groupValue: _selectedBank,
onChanged: (String? value) {
setState(() {
_selectedBank = value;
});
},
child: Column(
children: _banks.map(_bankCard).toList(),
),
),

const SizedBox(height: 8),

// ==================================================
// DEMO NOTE
// ==================================================

Container(
width: double.infinity,
padding: const EdgeInsets.all(14),
decoration: BoxDecoration(
color: const Color(0xFFFFF8E7),
borderRadius: BorderRadius.circular(16),
border: Border.all(
color: const Color(0xFFFFE0A3),
),
),
child: const Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Icon(
Icons.security_rounded,
color: Colors.orange,
size: 21,
),
SizedBox(width: 9),
Expanded(
child: Text(
'Demo Net Banking: use Customer ID '
'"demo" and Password "1234". '
'No real bank credentials are required.',
style: TextStyle(
color: Colors.black87,
fontSize: 11,
height: 1.45,
fontWeight: FontWeight.w600,
),
),
),
],
),
),

const SizedBox(height: 20),

// ==================================================
// CONTINUE BUTTON
// ==================================================

SizedBox(
width: double.infinity,
height: 56,
child: ElevatedButton(
onPressed:
_isProcessing
? null
    : _continueToBanking,
style: ElevatedButton.styleFrom(
backgroundColor: orange,
foregroundColor: darkGreen,
disabledBackgroundColor:
Colors.grey.shade300,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(16),
),
),
child: _isProcessing
? const SizedBox(
width: 24,
height: 24,
child: CircularProgressIndicator(
strokeWidth: 2.5,
color: darkGreen,
),
)
    : const Row(
mainAxisAlignment:
MainAxisAlignment.center,
children: [
Icon(
Icons.lock_outline_rounded,
size: 20,
),
SizedBox(width: 8),
Text(
'CONTINUE TO NET BANKING',
style: TextStyle(
fontSize: 13,
fontWeight: FontWeight.w900,
letterSpacing: 0.2,
),
),
],
),
),
),

const SizedBox(height: 14),

const Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Icon(
Icons.verified_user_outlined,
color: primaryGreen,
size: 17,
),
SizedBox(width: 6),
Flexible(
child: Text(
'Secure demo payment flow for Sangam Dairy.',
textAlign: TextAlign.center,
style: TextStyle(
color: textGrey,
fontSize: 10,
fontWeight: FontWeight.w500,
),
),
),
],
),
],
),
),
),
],
),
);
}
}