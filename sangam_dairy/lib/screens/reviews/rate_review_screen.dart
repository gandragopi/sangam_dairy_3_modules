import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RateReviewScreen extends StatefulWidget {
  final String orderId;
  final List<Map<String, dynamic>> items;

  const RateReviewScreen({
    super.key,
    required this.orderId,
    required this.items,
  });

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}

class _RateReviewScreenState extends State<RateReviewScreen> {
  static const Color primaryGreen = Color(0xFF087A35);
  static const Color darkGreen = Color(0xFF173B20);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color pageBackground = Color(0xFFF6F9F6);
  static const Color orange = Color(0xFFFFA916);

  static const String _reviewKey = 'sangam_dairy_reviews';

  int _deliveryRating = 0;

  final TextEditingController _reviewController =
  TextEditingController();

  final Map<String, int> _productRatings = {};

  bool _submitting = false;

  @override
  void initState() {
    super.initState();

    for (final item in widget.items) {
      final name = item['name']?.toString() ?? '';

      if (name.isNotEmpty) {
        _productRatings[name] = 0;
      }
    }

    _loadExistingReview();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // RATING TEXT
  // ------------------------------------------------------------

  String _ratingText(int rating) {
    switch (rating) {
      case 1:
        return 'Very Poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';
      case 5:
        return 'Excellent';
      default:
        return 'Tap a star to rate';
    }
  }

  // ------------------------------------------------------------
  // SECTION TITLE
  // ------------------------------------------------------------

  Widget _buildSectionTitle(
      String title,
      String subtitle,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: darkGreen,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // LOAD EXISTING REVIEW
  // ------------------------------------------------------------

  Future<void> _loadExistingReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString(_reviewKey);

      if (savedData == null || savedData.isEmpty) {
        return;
      }

      final decoded = jsonDecode(savedData);

      Map<String, dynamic> reviewsMap = {};

      // New format:
      // {
      //   "ORDER_ID": {
      //      "orderId": "...",
      //      "deliveryRating": 5,
      //      ...
      //   }
      // }
      if (decoded is Map) {
        reviewsMap = Map<String, dynamic>.from(decoded);
      }

      // Old format migration:
      // [
      //   {
      //      "orderId": "...",
      //      ...
      //   }
      // ]
      else if (decoded is List) {
        for (final item in decoded) {
          if (item is Map) {
            final review = Map<String, dynamic>.from(item);
            final orderId = review['orderId']?.toString() ?? '';

            if (orderId.isNotEmpty) {
              reviewsMap[orderId] = review;
            }
          }
        }

        await prefs.setString(
          _reviewKey,
          jsonEncode(reviewsMap),
        );
      }

      final existingReview = reviewsMap[widget.orderId];

      if (existingReview is! Map) {
        return;
      }

      final review = Map<String, dynamic>.from(existingReview);

      final deliveryRating = review['deliveryRating'];

      final savedProductRatings = review['productRatings'];

      if (!mounted) return;

      setState(() {
        if (deliveryRating is num) {
          _deliveryRating = deliveryRating.toInt();
        }

        if (savedProductRatings is Map) {
          for (final entry in savedProductRatings.entries) {
            final productName = entry.key.toString();
            final ratingValue = entry.value;

            if (ratingValue is num) {
              _productRatings[productName] = ratingValue.toInt();
            }
          }
        }

        _reviewController.text =
            review['review']?.toString() ?? '';
      });
    } catch (_) {
      // Ignore invalid or corrupt saved review data.
    }
  }

  // ------------------------------------------------------------
  // SUBMIT REVIEW
  // ------------------------------------------------------------

  Future<void> _submitReview() async {
    if (_deliveryRating == 0) {
      _showMessage(
        'Please rate your delivery experience.',
        Icons.star_outline_rounded,
      );
      return;
    }

    if (_submitting) return;

    setState(() {
      _submitting = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final existingData = prefs.getString(_reviewKey);

      Map<String, dynamic> reviewsMap = {};

      if (existingData != null && existingData.isNotEmpty) {
        try {
          final decoded = jsonDecode(existingData);

          if (decoded is Map) {
            reviewsMap = Map<String, dynamic>.from(decoded);
          } else if (decoded is List) {
            for (final item in decoded) {
              if (item is Map) {
                final oldReview =
                Map<String, dynamic>.from(item);

                final oldOrderId =
                    oldReview['orderId']?.toString() ?? '';

                if (oldOrderId.isNotEmpty) {
                  reviewsMap[oldOrderId] = oldReview;
                }
              }
            }
          }
        } catch (_) {
          reviewsMap = {};
        }
      }

      final productRatings = <String, int>{};

      _productRatings.forEach(
            (productName, rating) {
          if (rating > 0) {
            productRatings[productName] = rating;
          }
        },
      );

      final review = <String, dynamic>{
        'orderId': widget.orderId,
        'deliveryRating': _deliveryRating,
        'productRatings': productRatings,
        'review': _reviewController.text.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      };

      // Save using ORDER ID as the key.
      // Existing review for the same order will be updated.
      reviewsMap[widget.orderId] = review;

      await prefs.setString(
        _reviewKey,
        jsonEncode(reviewsMap),
      );

      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      await _showSuccessDialog();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _submitting = false;
      });

      _showMessage(
        'Unable to submit review. Please try again.',
        Icons.error_outline_rounded,
      );
    }
  }

  // ------------------------------------------------------------
  // SUCCESS DIALOG
  // ------------------------------------------------------------

  Future<void> _showSuccessDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: primaryGreen,
                    size: 52,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thank You!',
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your feedback helps us improve the Sangam Dairy experience.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'DONE',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted) return;

    Navigator.pop(context);
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        16,
        18,
        20,
      ),
      decoration: const BoxDecoration(
        color: darkGreen,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rate & Review',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tell us about your Sangam experience',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.12,
                ),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                'assets/images/sangam_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_drink_rounded,
                    color: Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // ORDER INFO
  // ------------------------------------------------------------

  Widget _buildOrderInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: primaryGreen,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.orderId,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: darkGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // DELIVERY RATING
  // ------------------------------------------------------------

  Widget _buildRatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_shipping_rounded,
            color: primaryGreen,
            size: 30,
          ),
          const SizedBox(height: 10),
          const Text(
            'How was your delivery?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Rate your overall delivery experience',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 18),
          _buildStars(
            rating: _deliveryRating,
            onChanged: (rating) {
              setState(() {
                _deliveryRating = rating;
              });
            },
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            _ratingText(_deliveryRating),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STARS
  // ------------------------------------------------------------

  Widget _buildStars({
    required int rating,
    required ValueChanged<int> onChanged,
    double size = 38,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
            (index) {
          final starNumber = index + 1;

          return GestureDetector(
            onTap: () {
              onChanged(starNumber);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
              child: Icon(
                starNumber <= rating
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                size: size,
                color: orange,
              ),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCT RATINGS
  // ------------------------------------------------------------

  Widget _buildProductRatings() {
    if (_productRatings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Rate your products',
            'How did you like the products you ordered?',
          ),
          const SizedBox(height: 18),
          ..._productRatings.entries.map(
                (entry) {
              return Padding(
                padding: const EdgeInsets.only(
                  bottom: 16,
                ),
                child: _buildProductRatingRow(
                  entry.key,
                  entry.value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCT RATING ROW
  // ------------------------------------------------------------

  Widget _buildProductRatingRow(
      String productName,
      int rating,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: pageBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
            ),
            child: _productImage(productName),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: darkGreen,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
                  (index) {
                final starNumber = index + 1;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _productRatings[productName] = starNumber;
                    });
                  },
                  child: Icon(
                    starNumber <= rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: orange,
                    size: 25,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // PRODUCT IMAGE
  // ------------------------------------------------------------

  Widget _productImage(String productName) {
    String? imagePath;

    for (final item in widget.items) {
      if (item['name']?.toString() == productName) {
        imagePath = item['image']?.toString();
        break;
      }
    }

    if (imagePath == null || imagePath.isEmpty) {
      return const Icon(
        Icons.shopping_bag_outlined,
        color: primaryGreen,
        size: 24,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(
            Icons.shopping_bag_outlined,
            color: primaryGreen,
            size: 24,
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // REVIEW BOX
  // ------------------------------------------------------------

  Widget _buildReviewBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(
            'Write a review',
            'Share anything you would like us to know.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            maxLines: 5,
            maxLength: 300,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              hintText: 'Tell us about your experience...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 13,
              ),
              filled: true,
              fillColor: pageBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: primaryGreen,
                  width: 1.2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SUBMIT BUTTON
  // ------------------------------------------------------------

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submitReview,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: _submitting
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.send_rounded,
              size: 20,
            ),
            SizedBox(width: 9),
            Text(
              'SUBMIT REVIEW',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(
      String message,
      IconData icon,
      ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: darkGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                30,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                    children: [
                      _buildOrderInfo(),
                      const SizedBox(height: 18),
                      _buildRatingCard(),
                      const SizedBox(height: 18),
                      _buildProductRatings(),
                      if (_productRatings.isNotEmpty)
                        const SizedBox(height: 18),
                      _buildReviewBox(),
                      const SizedBox(height: 18),
                      _buildSubmitButton(),
                      const SizedBox(height: 12),
                      Text(
                        'Your feedback is stored securely on this device.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
