import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BannerModel {
  final String id;
  String title;
  String subtitle;
  String tag;
  String imageUrl;
  bool isActive;

  BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
    this.isActive = true,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      tag: json['tag']?.toString() ?? 'PROMO',
      imageUrl: json['imageUrl']?.toString() ?? '',
      isActive: json['isActive'] ?? json['active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'tag': tag,
        'imageUrl': imageUrl,
        'active': isActive,
      };
}

class BannerApiService {
  static final BannerApiService _instance = BannerApiService._internal();
  factory BannerApiService() => _instance;
  BannerApiService._internal();

  String baseUrl = 'http://localhost:8080/api/banners';
  bool isLiveServerConnected = false;

  final List<BannerModel> _mockBanners = [
    BannerModel(
      id: 'BAN-01',
      title: 'Fresh Cow Ghee Festival Offer',
      subtitle: 'Flat ₹50 OFF on all 500ml & 1L Ghee packs',
      tag: 'SPECIAL OFFER',
      imageUrl: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=600',
      isActive: true,
    ),
    BannerModel(
      id: 'BAN-02',
      title: 'Morning Pure Milk Delivery',
      subtitle: 'Subscribe monthly & get 2 days free delivery',
      tag: 'SUBSCRIPTION',
      imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600',
      isActive: true,
    ),
    BannerModel(
      id: 'BAN-03',
      title: 'Delicious Dairy Sweets & Paneer',
      subtitle: 'Handcrafted fresh paneer & malai peda everyday',
      tag: 'FRESH DAILY',
      imageUrl: 'https://images.unsplash.com/photo-1587314168485-3236d6710814?w=600',
      isActive: false,
    ),
  ];

  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        List rawList = decoded is List ? decoded : (decoded['content'] ?? []);
        isLiveServerConnected = true;
        final apiBanners = rawList.map((b) => BannerModel.fromJson(Map<String, dynamic>.from(b))).toList();
        if (apiBanners.isNotEmpty) {
          _mockBanners.clear();
          _mockBanners.addAll(apiBanners);
        }
        return apiBanners;
      }
    } catch (e) {
      if (kDebugMode) print('Banner API offline ($e). Using mock banners.');
      isLiveServerConnected = false;
    }
    return List.from(_mockBanners);
  }

  Future<void> saveBanner(BannerModel banner) async {
    try {
      await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(banner.toJson()),
      ).timeout(const Duration(seconds: 4));
    } catch (e) {
      if (kDebugMode) print('saveBanner API exception: $e');
    }
  }

  Future<void> deleteBanner(String id) async {
    try {
      await http.delete(Uri.parse('$baseUrl/$id')).timeout(const Duration(seconds: 4));
    } catch (e) {
      if (kDebugMode) print('deleteBanner API exception: $e');
    }
  }
}
