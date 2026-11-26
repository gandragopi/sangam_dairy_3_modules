import 'package:flutter/material.dart';
import '../../services/banner_api_service.dart';

class BannersScreen extends StatefulWidget {
  const BannersScreen({super.key});

  @override
  State<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends State<BannersScreen> {
  final BannerApiService _bannerApi = BannerApiService();
  List<BannerModel> _banners = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBanners();
  }

  Future<void> _loadBanners() async {
    setState(() => _loading = true);
    final banners = await _bannerApi.getBanners();
    if (!mounted) return;
    setState(() {
      _banners = banners;
      _loading = false;
    });
  }

  void _showAddEditBannerDialog({BannerModel? banner}) {
    final titleController = TextEditingController(text: banner?.title ?? '');
    final subtitleController = TextEditingController(text: banner?.subtitle ?? '');
    final tagController = TextEditingController(text: banner?.tag ?? 'PROMO');
    final imageController = TextEditingController(text: banner?.imageUrl ?? '');
    bool isActive = banner?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(banner == null ? 'Add Promotional Banner' : 'Edit Banner'),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Banner Title', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subtitleController,
                    decoration: const InputDecoration(labelText: 'Subtitle / Description', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tagController,
                    decoration: const InputDecoration(labelText: 'Badge Tag (e.g., SPECIAL OFFER)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: imageController,
                    decoration: const InputDecoration(labelText: 'Banner Image URL', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active on Customer App'),
                    value: isActive,
                    onChanged: (val) => setDialogState(() => isActive = val),
                    activeThumbColor: const Color(0xFF087A35),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF087A35), foregroundColor: Colors.white),
              onPressed: () async {
                if (titleController.text.trim().isEmpty) return;
                final newBanner = BannerModel(
                  id: banner?.id ?? 'BAN-0${_banners.length + 1}',
                  title: titleController.text.trim(),
                  subtitle: subtitleController.text.trim(),
                  tag: tagController.text.trim(),
                  imageUrl: imageController.text.trim().isEmpty
                      ? 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=600'
                      : imageController.text.trim(),
                  isActive: isActive,
                );

                await _bannerApi.saveBanner(newBanner);
                await _loadBanners();
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(banner == null ? 'Banner added successfully' : 'Banner updated')),
                );
              },
              child: Text(banner == null ? 'Add Banner' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const brandGreen = Color(0xFF087A35);

    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: brandGreen));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F4),
      body: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'App Promotional Banners',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172D1E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Manage hero carousels and promotional banners displayed on customer mobile apps.',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditBannerDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add Banner', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 420,
                  mainAxisExtent: 260,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                ),
                itemCount: _banners.length,
                itemBuilder: (context, index) {
                  final banner = _banners[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2EBE3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: Image.network(
                                  banner.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.green.shade50,
                                    child: const Center(child: Icon(Icons.image, size: 40, color: brandGreen)),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                left: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: brandGreen,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    banner.tag,
                                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Switch(
                                  value: banner.isActive,
                                  activeThumbColor: brandGreen,
                                  onChanged: (val) async {
                                    setState(() => banner.isActive = val);
                                    await _bannerApi.saveBanner(banner);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                banner.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF172D1E)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                banner.subtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _showAddEditBannerDialog(banner: banner),
                                    icon: const Icon(Icons.edit_outlined, size: 16),
                                    label: const Text('Edit'),
                                    style: TextButton.styleFrom(foregroundColor: brandGreen),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Banner?'),
                                          content: Text('Are you sure you want to delete "${banner.title}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                              onPressed: () async {
                                                await _bannerApi.deleteBanner(banner.id);
                                                await _loadBanners();
                                                if (!context.mounted) return;
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Banner deleted')),
                                                );
                                              },
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                    label: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
