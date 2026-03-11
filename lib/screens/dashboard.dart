import 'package:excel/screens/profile_screen.dart';
import 'package:excel/widgets/recents.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

import 'package:excel/widgets/app_bar.dart';
import '../app_styles/app_colors.dart';
import '../providers/waste_item_provider.dart';
import '../providers/user_provider.dart'; // import user provider
import '../widgets/bottom_nav.dart';
import '../widgets/custom_loader.dart';
import 'image_preview_screen.dart';
import '../utils/camera.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  void _cameraClick() async{
    File? imageFile = await CameraUtils.pickImageFromCamera();

    if (imageFile != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewScreen(imageFile: imageFile),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final appColors = ref.watch(appColorsProvider);
    // Watch profile provider to ensure it's loaded and available for other screens like DetectionScreen
    ref.watch(currentUserProfileProvider);
    
    // Define pages for bottom navigation
    final List<Widget> pages = [
      _buildHomeContent(context, ref, appColors), // Home
      const Center(child: Text("Shop Screen Placeholder")), // Shop
      const Center(child: Text("Settings Screen Placeholder")), // Settings
      const ProfileScreen(), // Profile
    ];

    return Scaffold(
      backgroundColor: appColors.background,
      extendBody: true,
      floatingActionButton: SizedBox(
        height: 70,
        width: 70,
        child: FloatingActionButton(
          onPressed: () {
            _cameraClick();
          },
          shape: const CircleBorder(),
          backgroundColor: appColors.gold,
          elevation: 4,
          child: Icon(Icons.camera_alt_outlined, color: Colors.white , size: 32,),
        ),
      ),
      appBar: const AppAppBar(name: "Waste Detection",),

      body: pages[_currentIndex],

      bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: (int value) {
        setState(() {
          _currentIndex = value;
        });
      },),
    );
  }

  Widget _buildHomeContent(BuildContext context, WidgetRef ref, dynamic appColors) {
    final wasteItemList = ref.watch(wasteItemListProvider);
    
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                  "Recents",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: appColors.textPrimary,
                      letterSpacing: 0.5
                  )
              ),
            ),
            wasteItemList.when(
              data: (items) => ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  // Show newest items first
                  final item = items[items.length - 1 - index];
                  return Recents(
                    file: item.file,
                    wasteType: item.wasteType,
                    quantity: item.qty,
                    location: 'DUMMY LOCATION', // We will update this later with real location
                    date: 'TODAY', // We will update this later with real date
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context, 
                        builder: (context) => AlertDialog(
                          backgroundColor: appColors.background2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: appColors.divider, width: 1),
                          ),
                          title: Text(
                            'Delete Item',
                            style: TextStyle(
                              color: appColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to delete this item?',
                            style: TextStyle(
                              color: appColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false), 
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: appColors.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true), 
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        )
                      );
                      
                      if (confirm == true) {
                        ref.read(wasteItemListProvider.notifier).deleteWasteItem(item);
                      }
                    },
                  );
                },
              ),
              error: (err, stack) => Text('Error: $err'),
              loading: () => const ClassicLoader(),
            ),
            const SizedBox(height: 130,)
          ],
        ),
      );
  }
}

