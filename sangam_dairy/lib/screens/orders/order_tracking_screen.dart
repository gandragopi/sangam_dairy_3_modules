import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderTrackingScreen extends StatefulWidget {
final String orderId;
final double totalAmount;
final String paymentMethod;
final String customerName;
final String mobile;
final String address;
final String city;
final String pincode;
final List<Map<String, dynamic>> items;
final String status;

const OrderTrackingScreen({
super.key,
required this.orderId,
required this.totalAmount,
required this.paymentMethod,
required this.customerName,
required this.mobile,
required this.address,
required this.city,
required this.pincode,
required this.items,
required this.status,
});

@override
State<OrderTrackingScreen> createState() =>
_OrderTrackingScreenState();
}

class _OrderTrackingScreenState
extends State<OrderTrackingScreen> {
static const Color primaryGreen = Color(0xFF087A35);
static const Color darkGreen = Color(0xFF173B20);
static const Color lightGreen = Color(0xFFE8F5E9);
static const Color pageBackground = Color(0xFFF6F9F6);
static const Color orange = Color(0xFFFFA916);
static const Color cream = Color(0xFFFFFCF5);

// ============================================================
// NORMALIZED STATUS
// ============================================================

String get _currentStatus {
final value = widget.status.trim().toLowerCase();

if (value.contains('delivered')) {
return 'Delivered';
}

if (value.contains('out for delivery')) {
return 'Out for Delivery';
}

if (value.contains('preparing')) {
return 'Preparing';
}

if (value.contains('confirmed')) {
return 'Order Confirmed';
}

return 'Order Placed';
}

// ============================================================
// STATUS INDEX
// ============================================================

int get _currentStatusIndex {
switch (_currentStatus) {
case 'Order Confirmed':
return 1;

case 'Preparing':
return 2;

case 'Out for Delivery':
return 3;

case 'Delivered':
return 4;

case 'Order Placed':
default:
return 0;
}
}

bool get _isDelivered {
return _currentStatus == 'Delivered';
}

// ============================================================
// ITEM TOTAL
// ============================================================

double get _itemTotal {
double total = 0;

for (final item in widget.items) {
final price = _toDouble(item['price']);
final quantity = _toInt(item['quantity']);

total += price * quantity;
}

return total;
}

// ============================================================
// ADDITIONAL CHARGES
//
// The tracking screen receives only the final total.
// Therefore the difference between final total and item total
// is shown as Delivery & Service Charges.
// ============================================================

double get _deliveryAndServiceCharges {
final difference = widget.totalAmount - _itemTotal;

if (difference <= 0) {
return 0;
}

return difference;
}

double get _handlingFee {
return 0;
}

double get _platformFee {
return 0;
}

double get _discount {
return 0;
}

// ============================================================
// GST DISPLAY
//
// Do not add arbitrary GST again when product prices are already
// tax-inclusive. Actual GST should eventually come from backend.
// ============================================================

String get _gstText {
return 'Included in applicable prices';
}

// ============================================================
// CANCEL ORDER
// ============================================================

bool get _canCancelOrder {
return !_isDelivered &&
_currentStatus != 'Out for Delivery';
}

Future<void> _cancelOrder() async {
if (!_canCancelOrder) {
return;
}

final shouldCancel = await showDialog<bool>(
context: context,
builder: (dialogContext) {
return AlertDialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(22),
),
title: const Text(
'Cancel Order?',
style: TextStyle(
color: darkGreen,
fontWeight: FontWeight.w900,
),
),
content: const Text(
'Are you sure you want to cancel this order?',
style: TextStyle(
color: Colors.black54,
height: 1.4,
),
),
actions: [
TextButton(
onPressed: () {
Navigator.of(dialogContext).pop(false);
},
child: const Text(
'Keep Order',
style: TextStyle(
color: darkGreen,
fontWeight: FontWeight.w700,
),
),
),
ElevatedButton(
onPressed: () {
Navigator.of(dialogContext).pop(true);
},
style: ElevatedButton.styleFrom(
backgroundColor: const Color(0xFFD64545),
foregroundColor: Colors.white,
elevation: 0,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
),
),
child: const Text(
'Cancel Order',
style: TextStyle(
fontWeight: FontWeight.w800,
),
),
),
],
);
},
);

if (shouldCancel != true) {
return;
}

final prefs = await SharedPreferences.getInstance();

final cancelledIds =
prefs.getStringList('sangam_cancelled_orders') ??
<String>[];

if (!cancelledIds.contains(widget.orderId)) {
cancelledIds.add(widget.orderId);
}

await prefs.setStringList(
'sangam_cancelled_orders',
cancelledIds,
);

if (!mounted) {
return;
}

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
'Order cancelled successfully.',
),
backgroundColor: Color(0xFFD64545),
),
);

await Future<void>.delayed(
const Duration(milliseconds: 350),
);

if (!mounted) {
return;
}

Navigator.of(context).pop(true);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(
backgroundColor: pageBackground,
appBar: AppBar(
backgroundColor: Colors.white,
elevation: 0,
centerTitle: true,
leading: IconButton(
icon: const Icon(
Icons.arrow_back_ios_new,
color: darkGreen,
),
onPressed: () => Navigator.pop(context),
),
title: const Text(
'Order Tracking',
style: TextStyle(
color: darkGreen,
fontSize: 20,
fontWeight: FontWeight.w800,
),
),
),
body: SafeArea(
child: LayoutBuilder(
builder: (context, constraints) {
final isDesktop = constraints.maxWidth >= 900;

return SingleChildScrollView(
padding: EdgeInsets.symmetric(
horizontal: isDesktop ? 50 : 18,
vertical: 20,
),
child: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(
maxWidth: 1100,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildOrderHeader(),

const SizedBox(height: 18),

if (isDesktop)
Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Expanded(
flex: 6,
child: _buildTrackingCard(),
),
const SizedBox(width: 18),
Expanded(
flex: 4,
child: Column(
children: [
_buildDeliveryCard(),

const SizedBox(height: 18),

_buildPaymentCard(),

const SizedBox(height: 18),

_buildBillDetailsCard(),
],
),
),
],
)
else ...[
_buildTrackingCard(),

const SizedBox(height: 18),

_buildDeliveryCard(),

const SizedBox(height: 18),

_buildPaymentCard(),

const SizedBox(height: 18),

_buildBillDetailsCard(),
],

const SizedBox(height: 18),

_buildItemsCard(),

if (_canCancelOrder) ...[
const SizedBox(height: 18),
_buildCancelOrderButton(),
],

const SizedBox(height: 25),
],
),
),
),
);
},
),
),
);
}

// ============================================================
// ORDER HEADER
// ============================================================

Widget _buildOrderHeader() {
final bool delivered = _isDelivered;

String headerTitle;

switch (_currentStatus) {
case 'Order Confirmed':
headerTitle = 'Your order has been confirmed';
break;

case 'Preparing':
headerTitle = 'Your order is being prepared';
break;

case 'Out for Delivery':
headerTitle = 'Your order is out for delivery';
break;

case 'Delivered':
headerTitle = 'Your order has been delivered';
break;

case 'Order Placed':
default:
headerTitle = 'Your order has been placed';
break;
}

return Container(
width: double.infinity,
padding: const EdgeInsets.all(22),
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
darkGreen,
primaryGreen,
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(24),
boxShadow: [
BoxShadow(
color: primaryGreen.withValues(alpha: 0.18),
blurRadius: 18,
offset: const Offset(0, 8),
),
],
),
child: Row(
children: [
Container(
width: 58,
height: 58,
decoration: BoxDecoration(
color: Colors.white.withValues(alpha: 0.14),
shape: BoxShape.circle,
),
child: Icon(
delivered
? Icons.check_circle_outline_rounded
    : Icons.local_shipping_outlined,
color: Colors.white,
size: 30,
),
),

const SizedBox(width: 16),

Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
headerTitle,
style: const TextStyle(
color: Colors.white,
fontSize: 19,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 6),

Text(
'Order ID: ${widget.orderId}',
style: TextStyle(
color: Colors.white.withValues(
alpha: 0.82,
),
fontSize: 13,
fontWeight: FontWeight.w500,
),
),
],
),
),

const SizedBox(width: 10),

Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 8,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
),
child: Text(
_currentStatus.toUpperCase(),
textAlign: TextAlign.center,
style: const TextStyle(
color: primaryGreen,
fontSize: 10,
fontWeight: FontWeight.w900,
),
),
),
],
),
);
}

// ============================================================
// TRACKING CARD
// ============================================================

Widget _buildTrackingCard() {
return _buildCard(
title: 'Delivery Status',
icon: Icons.route_outlined,
child: Column(
children: [
_buildDeliveryRoute(),

const SizedBox(height: 18),

_buildTimelineItem(
icon: Icons.shopping_bag_outlined,
title: 'Order Placed',
subtitle: 'Your order has been received',
stepIndex: 0,
isLast: false,
),

_buildTimelineItem(
icon: Icons.check_circle_outline,
title: 'Order Confirmed',
subtitle:
'Sangam Dairy has confirmed your order',
stepIndex: 1,
isLast: false,
),

_buildTimelineItem(
icon: Icons.inventory_2_outlined,
title: 'Preparing',
subtitle:
'Your fresh dairy products are being prepared',
stepIndex: 2,
isLast: false,
),

_buildTimelineItem(
icon: Icons.delivery_dining_outlined,
title: 'Out for Delivery',
subtitle:
'Your order is on its way to you',
stepIndex: 3,
isLast: false,
),

_buildTimelineItem(
icon: Icons.home_outlined,
title: 'Delivered',
subtitle: _isDelivered
? 'Your order has been delivered successfully'
    : 'This step will be completed after delivery',
stepIndex: 4,
isLast: true,
),
],
),
);
}

// ============================================================
// DELIVERY ROUTE / MAP
// ============================================================

Widget _buildDeliveryRoute() {
final bool outForDelivery =
_currentStatus == 'Out for Delivery' || _isDelivered;

return Container(
width: double.infinity,
height: 300,
decoration: BoxDecoration(
color: const Color(0xFFEAF1EA),
borderRadius: BorderRadius.circular(20),
border: Border.all(
color: const Color(0xFFDCE7DE),
),
),
clipBehavior: Clip.antiAlias,
child: Stack(
children: [
Positioned.fill(
child: CustomPaint(
painter: _DeliveryMapPainter(
showPartner: outForDelivery,
),
),
),

Positioned(
left: 14,
top: 14,
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 12,
vertical: 8,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.08),
blurRadius: 10,
offset: const Offset(0, 3),
),
],
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(
Icons.location_on_rounded,
color: primaryGreen,
size: 18,
),
const SizedBox(width: 6),
Text(
outForDelivery
? 'Delivery route'
    : 'Delivery route preview',
style: const TextStyle(
color: darkGreen,
fontSize: 12.5,
fontWeight: FontWeight.w800,
),
),
],
),
),
),

Positioned(
left: 16,
bottom: 14,
child: _buildMapLabel(
icon: Icons.storefront_rounded,
text: 'Sangam Dairy',
),
),

Positioned(
right: 16,
bottom: 14,
child: _buildMapLabel(
icon: Icons.home_rounded,
text: 'Your Home',
),
),

if (outForDelivery)
Positioned(
left: 0,
right: 0,
top: 135,
child: Center(
child: Container(
padding: const EdgeInsets.symmetric(
horizontal: 11,
vertical: 8,
),
decoration: BoxDecoration(
color: primaryGreen,
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: primaryGreen.withValues(alpha: 0.25),
blurRadius: 12,
offset: const Offset(0, 5),
),
],
),
child: const Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
Icons.delivery_dining_rounded,
color: Colors.white,
size: 17,
),
SizedBox(width: 6),
Text(
'Delivery Partner',
style: TextStyle(
color: Colors.white,
fontSize: 12,
fontWeight: FontWeight.w800,
),
),
],
),
),
),
),

Positioned(
right: 14,
top: 14,
child: Container(
padding: const EdgeInsets.all(9),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(12),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.07),
blurRadius: 9,
offset: const Offset(0, 3),
),
],
),
child: const Icon(
Icons.my_location_rounded,
color: primaryGreen,
size: 19,
),
),
),
],
),
);
}

Widget _buildMapLabel({
required IconData icon,
required String text,
}) {
return Container(
padding: const EdgeInsets.symmetric(
horizontal: 10,
vertical: 7,
),
decoration: BoxDecoration(
color: Colors.white.withValues(alpha: 0.95),
borderRadius: BorderRadius.circular(11),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(alpha: 0.07),
blurRadius: 8,
offset: const Offset(0, 3),
),
],
),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
icon,
color: primaryGreen,
size: 16,
),
const SizedBox(width: 5),
Text(
text,
style: const TextStyle(
color: darkGreen,
fontSize: 11.5,
fontWeight: FontWeight.w800,
),
),
],
),
);
}

// ============================================================
// TIMELINE ITEM
// ============================================================

Widget _buildTimelineItem({
required IconData icon,
required String title,
required String subtitle,
required int stepIndex,
required bool isLast,
}) {
final bool completed =
stepIndex <= _currentStatusIndex;

final bool current =
stepIndex == _currentStatusIndex &&
!_isDelivered;

final Color itemColor = completed
? primaryGreen
    : Colors.grey.shade400;

final Color circleBackground = completed
? lightGreen
    : Colors.grey.shade100;

return Row(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(
width: 48,
child: Column(
children: [
Container(
width: 42,
height: 42,
decoration: BoxDecoration(
color: circleBackground,
shape: BoxShape.circle,
border: Border.all(
color: itemColor,
width: current ? 2 : 1.5,
),
),
child: Icon(
icon,
color: itemColor,
size: 21,
),
),

if (!isLast)
Container(
width: 2,
height: 52,
margin: const EdgeInsets.symmetric(
vertical: 3,
),
color: stepIndex < _currentStatusIndex
? primaryGreen
    : Colors.grey.shade300,
),
],
),
),

const SizedBox(width: 14),

Expanded(
child: Padding(
padding: const EdgeInsets.only(
top: 3,
),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Expanded(
child: Text(
title,
style: TextStyle(
color: completed
? darkGreen
    : Colors.grey.shade600,
fontSize: 16,
fontWeight: FontWeight.w800,
),
),
),

if (completed)
const Icon(
Icons.check_circle,
color: primaryGreen,
size: 19,
),
],
),

const SizedBox(height: 5),

Text(
subtitle,
style: TextStyle(
color: completed
? Colors.grey.shade600
    : Colors.grey.shade500,
fontSize: 12.5,
height: 1.35,
),
),

SizedBox(
height: isLast ? 4 : 18,
),
],
),
),
),
],
);
}

// ============================================================
// DELIVERY DETAILS
// ============================================================

Widget _buildDeliveryCard() {
return _buildCard(
title: 'Delivery Details',
icon: Icons.location_on_outlined,
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_detailRow(
Icons.person_outline,
'Customer',
widget.customerName,
),

const SizedBox(height: 12),

_detailRow(
Icons.phone_outlined,
'Mobile',
widget.mobile.isEmpty ? '-' : widget.mobile,
),

const SizedBox(height: 12),

_detailRow(
Icons.location_on_outlined,
'Address',
[
widget.address,
widget.city,
widget.pincode,
]
    .where(
(value) =>
value.trim().isNotEmpty,
)
    .join(', '),
),

const SizedBox(height: 16),

Container(
width: double.infinity,
padding: const EdgeInsets.all(13),
decoration: BoxDecoration(
color: _isDelivered
? lightGreen
    : const Color(0xFFFFF4DF),
borderRadius:
BorderRadius.circular(14),
),
child: Row(
children: [
Icon(
_isDelivered
? Icons.check_circle_outline
    : Icons.access_time_rounded,
color: _isDelivered
? primaryGreen
    : orange,
size: 20,
),

const SizedBox(width: 10),

Expanded(
child: Text(
_isDelivered
? 'Delivered Successfully'
    : 'Current Status: $_currentStatus',
style: TextStyle(
color: _isDelivered
? darkGreen
    : const Color(0xFF8A5A00),
fontWeight: FontWeight.w700,
fontSize: 13,
),
),
),
],
),
),
],
),
);
}

// ============================================================
// PAYMENT LOGO
// ============================================================

Widget _paymentLogo() {
final String method =
widget.paymentMethod.trim().toLowerCase();

if (method.contains('phonepe')) {
return Image.asset(
'assets/images/phonepe.png',
width: 46,
height: 46,
fit: BoxFit.contain,
errorBuilder: (
context,
error,
stackTrace,
) {
return const Icon(
Icons.phone_android_rounded,
color: primaryGreen,
size: 30,
);
},
);
}

if (method.contains('google pay') ||
method.contains('gpay')) {
return Image.asset(
'assets/images/google_pay.png',
width: 46,
height: 46,
fit: BoxFit.contain,
errorBuilder: (
context,
error,
stackTrace,
) {
return const Icon(
Icons.account_balance_wallet_rounded,
color: primaryGreen,
size: 30,
);
},
);
}

return const Icon(
Icons.payment_outlined,
color: primaryGreen,
size: 25,
);
}

// ============================================================
// PAYMENT CARD
// ============================================================

Widget _buildPaymentCard() {
return _buildCard(
title: 'Payment',
icon: Icons.account_balance_wallet_outlined,
child: Row(
children: [
Container(
width: 52,
height: 52,
padding: const EdgeInsets.all(3),
decoration: BoxDecoration(
color: lightGreen,
borderRadius:
BorderRadius.circular(13),
),
child: _paymentLogo(),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
widget.paymentMethod.isEmpty
? 'Payment'
    : widget.paymentMethod,
style: const TextStyle(
color: darkGreen,
fontSize: 14,
fontWeight: FontWeight.w800,
),
),

const SizedBox(height: 4),

Text(
'Amount paid',
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
),
),
],
),
),

Text(
_currency(widget.totalAmount),
style: const TextStyle(
color: primaryGreen,
fontSize: 18,
fontWeight: FontWeight.w900,
),
),
],
),
);
}

// ============================================================
// BILL DETAILS
// ============================================================

Widget _buildBillDetailsCard() {
return _buildCard(
title: 'Bill Details',
icon: Icons.receipt_long_outlined,
child: Column(
children: [
_billRow(
'Item Total',
_currency(_itemTotal),
),

const SizedBox(height: 12),

_billRow(
'Delivery & Service Charges',
_deliveryAndServiceCharges <= 0
? 'FREE'
    : _currency(_deliveryAndServiceCharges),
valueColor:
_deliveryAndServiceCharges <= 0
? primaryGreen
    : darkGreen,
),

const SizedBox(height: 12),

_billRow(
'Handling Fee',
_handlingFee <= 0
? 'FREE'
    : _currency(_handlingFee),
valueColor: primaryGreen,
),

const SizedBox(height: 12),

_billRow(
'Platform Fee',
_platformFee <= 0
? 'FREE'
    : _currency(_platformFee),
valueColor: primaryGreen,
),

const SizedBox(height: 12),

_billRow(
'Discount',
_discount > 0
? '-${_currency(_discount)}'
    : '₹0',
valueColor:
_discount > 0
? primaryGreen
    : Colors.grey.shade600,
),

const SizedBox(height: 14),

Divider(
color: Colors.grey.shade200,
height: 1,
),

const SizedBox(height: 14),

Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
const Expanded(
child: Text(
'GST',
style: TextStyle(
color: darkGreen,
fontSize: 13,
fontWeight: FontWeight.w700,
),
),
),

const SizedBox(width: 12),

Flexible(
child: Text(
_gstText,
textAlign: TextAlign.right,
style: TextStyle(
color: Colors.grey.shade600,
fontSize: 12,
fontWeight: FontWeight.w600,
),
),
),
],
),

const SizedBox(height: 16),

Container(
width: double.infinity,
padding: const EdgeInsets.all(15),
decoration: BoxDecoration(
color: cream,
borderRadius:
BorderRadius.circular(16),
border: Border.all(
color: const Color(0xFFE8DFC9),
),
),
child: Row(
children: [
const Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
'To Pay',
style: TextStyle(
color: darkGreen,
fontSize: 15,
fontWeight: FontWeight.w800,
),
),

SizedBox(height: 3),

Text(
'Final amount',
style: TextStyle(
color: Colors.grey,
fontSize: 11,
),
),
],
),
),

Text(
_currency(widget.totalAmount),
style: const TextStyle(
color: primaryGreen,
fontSize: 21,
fontWeight: FontWeight.w900,
),
),
],
),
),
],
),
);
}

// ============================================================
// BILL ROW
// ============================================================

Widget _billRow(
String label,
String value, {
Color? valueColor,
}) {
return Row(
children: [
Expanded(
child: Text(
label,
style: TextStyle(
color: Colors.grey.shade700,
fontSize: 13,
fontWeight: FontWeight.w600,
),
),
),

const SizedBox(width: 12),

Text(
value,
textAlign: TextAlign.right,
style: TextStyle(
color: valueColor ?? darkGreen,
fontSize: 13,
fontWeight: FontWeight.w800,
),
),
],
);
}

// ============================================================
// ORDERED ITEMS
// ============================================================

Widget _buildItemsCard() {
return _buildCard(
title: 'Ordered Items',
icon: Icons.shopping_basket_outlined,
child: widget.items.isEmpty
? Padding(
padding:
const EdgeInsets.symmetric(
vertical: 12,
),
child: Text(
'No item details available',
style: TextStyle(
color: Colors.grey.shade600,
),
),
)
    : Column(
children: List.generate(
widget.items.length,
(index) {
final item = widget.items[index];

final name =
item['name']?.toString() ??
'Product';

final image =
item['image']?.toString() ??
'';

final quantity =
_toInt(item['quantity']);

final price =
_toDouble(item['price']);

final itemTotal =
price * quantity;

return Container(
margin: EdgeInsets.only(
bottom:
index == widget.items.length - 1
? 0
    : 12,
),
padding:
const EdgeInsets.all(10),
decoration: BoxDecoration(
color: pageBackground,
borderRadius:
BorderRadius.circular(14),
border: Border.all(
color: Colors.grey.shade200,
),
),
child: Row(
crossAxisAlignment:
CrossAxisAlignment.center,
children: [
Container(
width: 64,
height: 64,
padding:
const EdgeInsets.all(6),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(
12,
),
),
child: image.isNotEmpty
? Image.asset(
image,
fit: BoxFit.contain,
errorBuilder: (
context,
error,
stackTrace,
) {
return const Icon(
Icons
    .image_not_supported_outlined,
color: Colors.grey,
);
},
)
    : const Icon(
Icons
    .shopping_basket_outlined,
color: primaryGreen,
),
),

const SizedBox(width: 12),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
name,
maxLines: 2,
overflow:
TextOverflow.ellipsis,
style:
const TextStyle(
color: darkGreen,
fontSize: 14,
fontWeight:
FontWeight.w800,
),
),

const SizedBox(height: 6),

Row(
children: [
Text(
'${_currency(price)} × $quantity',
style: TextStyle(
color: Colors
    .grey.shade600,
fontSize: 12,
fontWeight:
FontWeight.w600,
),
),
],
),
],
),
),

const SizedBox(width: 10),

Column(
crossAxisAlignment:
CrossAxisAlignment.end,
children: [
Text(
_currency(itemTotal),
style:
const TextStyle(
color: primaryGreen,
fontSize: 15,
fontWeight:
FontWeight.w900,
),
),

const SizedBox(height: 4),

Text(
'Item total',
style: TextStyle(
color:
Colors.grey.shade500,
fontSize: 10,
),
),
],
),
],
),
);
},
),
),
);
}

// ============================================================
// CANCEL ORDER BUTTON
// ============================================================

Widget _buildCancelOrderButton() {
return SizedBox(
width: double.infinity,
height: 48,
child: OutlinedButton.icon(
onPressed: _cancelOrder,
icon: const Icon(
Icons.cancel_outlined,
size: 19,
),
label: const Text(
'Cancel Order',
style: TextStyle(
fontSize: 14,
fontWeight: FontWeight.w800,
),
),
style: OutlinedButton.styleFrom(
foregroundColor: const Color(0xFFD64545),
side: const BorderSide(
color: Color(0xFFD64545),
width: 1.2,
),
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(14),
),
),
),
);
}

// ============================================================
// COMMON CARD
// ============================================================

Widget _buildCard({
required String title,
required IconData icon,
required Widget child,
}) {
return Container(
width: double.infinity,
padding: const EdgeInsets.all(20),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(22),
boxShadow: [
BoxShadow(
color: Colors.black.withValues(
alpha: 0.045,
),
blurRadius: 15,
offset: const Offset(0, 5),
),
],
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 38,
height: 38,
decoration: BoxDecoration(
color: lightGreen,
borderRadius:
BorderRadius.circular(11),
),
child: Icon(
icon,
color: primaryGreen,
size: 20,
),
),

const SizedBox(width: 11),

Expanded(
child: Text(
title,
style: const TextStyle(
color: darkGreen,
fontSize: 17,
fontWeight: FontWeight.w800,
),
),
),
],
),

const SizedBox(height: 18),

child,
],
),
);
}

// ============================================================
// DETAIL ROW
// ============================================================

Widget _detailRow(
IconData icon,
String label,
String value,
) {
return Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Icon(
icon,
size: 19,
color: primaryGreen,
),

const SizedBox(width: 10),

Expanded(
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Text(
label,
style: TextStyle(
color: Colors.grey.shade500,
fontSize: 11,
fontWeight: FontWeight.w600,
),
),

const SizedBox(height: 2),

Text(
value.trim().isEmpty
? '-'
    : value,
style: const TextStyle(
color: darkGreen,
fontSize: 13,
fontWeight: FontWeight.w700,
height: 1.35,
),
),
],
),
),
],
);
}

// ============================================================
// CURRENCY
// ============================================================

String _currency(double value) {
return '₹${value.toStringAsFixed(0)}';
}

// ============================================================
// DOUBLE CONVERTER
// ============================================================

double _toDouble(dynamic value) {
if (value is num) {
return value.toDouble();
}

return double.tryParse(
value?.toString() ?? '',
) ??
0;
}

// ============================================================
// INT CONVERTER
// ============================================================

int _toInt(dynamic value) {
if (value is int) {
return value;
}

if (value is num) {
return value.toInt();
}

return int.tryParse(
value?.toString() ?? '',
) ??
1;
}
}

class _DeliveryMapPainter extends CustomPainter {
final bool showPartner;

const _DeliveryMapPainter({
required this.showPartner,
});

@override
void paint(Canvas canvas, Size size) {
final Paint backgroundPaint = Paint()
..color = const Color(0xFFEAF1EA);
canvas.drawRect(
Offset.zero & size,
backgroundPaint,
);

final Paint roadPaint = Paint()
..color = Colors.white.withValues(alpha: 0.95)
..style = PaintingStyle.stroke
..strokeWidth = 34
..strokeCap = StrokeCap.round;

final Paint roadShadowPaint = Paint()
..color = const Color(0xFFD9E4DA)
..style = PaintingStyle.stroke
..strokeWidth = 39
..strokeCap = StrokeCap.round;

final List<Path> roads = [
Path()
..moveTo(-40, size.height * 0.28)
..cubicTo(
size.width * 0.20,
size.height * 0.12,
size.width * 0.48,
size.height * 0.34,
size.width + 40,
size.height * 0.20,
),
Path()
..moveTo(size.width * 0.12, size.height + 30)
..cubicTo(
size.width * 0.26,
size.height * 0.70,
size.width * 0.56,
size.height * 0.74,
size.width * 0.72,
-30,
),
Path()
..moveTo(-20, size.height * 0.78)
..cubicTo(
size.width * 0.34,
size.height * 0.58,
size.width * 0.68,
size.height * 0.92,
size.width + 30,
size.height * 0.66,
),
];

for (final road in roads) {
canvas.drawPath(road, roadShadowPaint);
canvas.drawPath(road, roadPaint);
}

final Paint smallRoadPaint = Paint()
..color = Colors.white.withValues(alpha: 0.72)
..style = PaintingStyle.stroke
..strokeWidth = 13
..strokeCap = StrokeCap.round;

final List<Path> smallRoads = [
Path()
..moveTo(size.width * 0.04, size.height * 0.55)
..quadraticBezierTo(
size.width * 0.45,
size.height * 0.44,
size.width * 0.96,
size.height * 0.48,
),
Path()
..moveTo(size.width * 0.46, size.height * 0.04)
..quadraticBezierTo(
size.width * 0.52,
size.height * 0.45,
size.width * 0.42,
size.height * 0.96,
),
];

for (final road in smallRoads) {
canvas.drawPath(road, smallRoadPaint);
}

final Path route = Path()
..moveTo(size.width * 0.14, size.height * 0.76)
..cubicTo(
size.width * 0.30,
size.height * 0.68,
size.width * 0.47,
size.height * 0.72,
size.width * 0.60,
size.height * 0.51,
)
..cubicTo(
size.width * 0.69,
size.height * 0.37,
size.width * 0.79,
size.height * 0.30,
size.width * 0.88,
size.height * 0.24,
);

final Paint routeShadow = Paint()
..color = const Color(0xFF087A35).withValues(alpha: 0.12)
..style = PaintingStyle.stroke
..strokeWidth = 10
..strokeCap = StrokeCap.round;

final Paint routePaint = Paint()
..color = const Color(0xFF087A35)
..style = PaintingStyle.stroke
..strokeWidth = 5
..strokeCap = StrokeCap.round;

canvas.drawPath(route, routeShadow);
canvas.drawPath(route, routePaint);

_drawMarker(
canvas,
Offset(size.width * 0.14, size.height * 0.76),
Icons.storefront_rounded,
const Color(0xFF087A35),
);

_drawMarker(
canvas,
Offset(size.width * 0.88, size.height * 0.24),
Icons.home_rounded,
const Color(0xFF173B20),
);

if (showPartner) {
_drawMarker(
canvas,
Offset(size.width * 0.60, size.height * 0.51),
Icons.delivery_dining_rounded,
const Color(0xFFFFA916),
);
}
}

void _drawMarker(
Canvas canvas,
Offset center,
IconData icon,
Color color,
) {
final Paint shadowPaint = Paint()
..color = Colors.black.withValues(alpha: 0.12);

canvas.drawCircle(
center + const Offset(0, 3),
22,
shadowPaint,
);

final Paint outerPaint = Paint()
..color = Colors.white;

canvas.drawCircle(
center,
22,
outerPaint,
);

final Paint innerPaint = Paint()
..color = color;

canvas.drawCircle(
center,
16,
innerPaint,
);

final TextPainter textPainter = TextPainter(
text: TextSpan(
text: String.fromCharCode(icon.codePoint),
style: TextStyle(
fontSize: 17,
fontFamily: icon.fontFamily,
package: icon.fontPackage,
color: Colors.white,
),
),
textDirection: TextDirection.ltr,
)..layout();

textPainter.paint(
canvas,
center - Offset(
textPainter.width / 2,
textPainter.height / 2,
),
);
}

@override
bool shouldRepaint(covariant _DeliveryMapPainter oldDelegate) {
return oldDelegate.showPartner != showPartner;
}
}


