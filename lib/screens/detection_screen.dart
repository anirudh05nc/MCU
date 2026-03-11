import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // import firebase_auth
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:excel/app_styles/app_button_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_styles/app_colors.dart';
import '../providers/waste_item_provider.dart';
import '../providers/user_provider.dart'; // import user_provider
import '../widgets/app_bar.dart';
import '../data/models/waste_item.dart';
import '../widgets/custom_loader.dart';

class DetectionScreen extends ConsumerWidget {
  final File? imageFile;
  final String waste;
  final String qty;
  final List<String> dispose;
  final List<String> donts;

  const DetectionScreen({
    super.key,
    required this.imageFile,
    required this.waste,
    required this.qty,
    required this.dispose,
    required this.donts,
  });

  Future<void> _addToFirestore(String wasteType, String quantity, WidgetRef ref) async {
    try {
      debugPrint('Attempting to add to Firestore...');

      final user = FirebaseAuth.instance.currentUser;
      final userProfile = ref.read(userProfileProvider);

      String? imageUrl;
      if (imageFile != null) {
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('waste_images/${DateTime.now().millisecondsSinceEpoch}.jpg');
          await storageRef.putFile(imageFile!);
          imageUrl = await storageRef.getDownloadURL();
        } catch (e) {
          debugPrint('Error uploading image: $e');
          // Proceed without image URL if upload fails, or Handle as critical error
        }
      }

      // Get Location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Get Address
      String address = 'Unknown Location';
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
            position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          address =
              '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
        }
      } catch (e) {
        debugPrint('Error getting address: $e');
      }

      await FirebaseFirestore.instance.collection('waste_items').add({
        'type': wasteType,
        'quantity': quantity,
        'qty': quantity,
        'location': address,
        'geo_location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'imageUrl': imageUrl,
        'time': FieldValue.serverTimestamp(),
        'dispose_ways': dispose,
        'donts': donts,
        // User Details
        'userId': user?.uid,
        'userEmail': user?.email,
        'userName': userProfile?.name ?? '',
        'userPhone': userProfile?.phone ?? '',
        'userAddress': userProfile?.address ?? '',
      });
      debugPrint('Added to Firestore successfully');
    } catch (e) {
      debugPrint('Error adding to Firestore: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = ref.watch(appColorsProvider);
    final appButtons = ref.watch(appButtonsProvider);

    final String wasteType = waste;
    final String quantity = "$qty Kgs";
    final List<String> disposalWays = dispose;
    final List<String> thingsNotToDo = donts;

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: const AppAppBar(name: "Detection Result"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageFile != null)
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: FileImage(imageFile!),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: appColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            _buildInfoCard(
              context,
              appColors,
              title: "Type of Waste",
              content: wasteType,
              icon: Icons.category_outlined,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              appColors,
              title: "Approx. Quantity",
              content: quantity,
              icon: Icons.scale_outlined,
            ),
            const SizedBox(height: 24),
            Text(
              "Ways to Dispose Effectively",
              style: TextStyle(
                color: appColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...disposalWays.map((way) => _buildDisposalStep(appColors, way)),
            const SizedBox(height: 24),
            Text(
              "Things NOT to do",
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...thingsNotToDo.map((way) => _buildDontStep(appColors, way)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: appButtons.themeOutlinedButton,
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: appColors.gold),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Show loading dialog
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                            const Center(child: ClassicLoader()),
                      );

                      try {
                        // 1. Add to Firestore (waste_items collection)
                        // Await this specifically to catch errors
                        await _addToFirestore(waste, qty, ref);

                        // 2. Save to Hive (Local Storage)
                        // This is less critical, can be done after or in parallel
                        await ref
                            .read(wasteItemListProvider.notifier)
                            .addWasteItem(
                              WasteItem(
                                id: DateTime.now().millisecondsSinceEpoch,
                                file: imageFile?.path ?? '',
                                wasteType: waste,
                                qty: qty,
                                dispose: dispose,
                                dont: donts,
                              ),
                            );

                        if (context.mounted) {
                          // Close the loading dialog
                          Navigator.pop(context);

                          // Navigate to Dashboard
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/', (route) => false);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Submitted Successfully')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          // Close the loading dialog
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Error submitting: $e. Check internet & permissions.')),
                          );
                        }
                        debugPrint("Error saving data: $e");
                      }
                    },
                    style: appButtons.themeButton,
                    child: Text(
                      "SUBMIT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, AppColors appColors,
      {required String title,
      required String content,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appColors.background2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.divider),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: appColors.gold, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: appColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: appColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisposalStep(AppColors appColors, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.background2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: appColors.gold, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDontStep(AppColors appColors, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: appColors.background2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: appColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: appColors.textPrimary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
