import 'dart:io';
import 'package:flutter/material.dart';
import '../app_styles/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme_provider.dart';

class Recents extends ConsumerWidget {
  // Add variables so you can pass different data for each recent item
  final String file;
  final String wasteType;
  final String quantity;
  final String location;
  final String date;
  final VoidCallback? onDelete; // Callback for delete action

  const Recents({
    super.key,
    required this.file,
    required this.wasteType, // Default values for testing
    required this.quantity,
    required this.location,
    required this.date,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final appColors = ref.watch(appColorsProvider);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      width: double.infinity,
      // Increased height slightly to accommodate the button if needed, 
      // but sticking to 140 works if we position the button well.
      height: 140, 
      decoration: BoxDecoration(
        color: appColors.background2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: appColors.divider,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: appColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              // 1. Image Placeholder
              Container(
                margin: const EdgeInsets.all(12),
                height: 116,
                width: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: appColors.secondary,
                  image: file.isNotEmpty 
                      ? DecorationImage(
                          image: FileImage(File(file)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: file.isEmpty 
                    ? Icon(Icons.image_outlined, color: appColors.textSecondary.withOpacity(0.5), size: 30)
                    : null,
              ),

              // 2. Details Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDetailRow("Type:", wasteType, appColors, isTitle: true),
                      const SizedBox(height: 8),
                      _buildDetailRow("Qty(kgs):", quantity, appColors),
                      const SizedBox(height: 4),
                      _buildDetailRow("Location:", location, appColors),
                      const SizedBox(height: 4),
                      _buildDetailRow("Time:", date, appColors),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Delete Button positioned at bottom-right (or top-right depending on preference)
          // User said "below to the details add a button", but inside the row layout 
          // a button below the details might get cramped. 
          // Let's place it at the bottom right corner of the card or end of the row.
          
          Positioned(
            right: 8,
            bottom: 8,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              tooltip: 'Delete',
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to style the text rows consistently
  Widget _buildDetailRow(String label, String value, AppColors appColors, {bool isTitle = false}) {
    return Row(
      children: [
        Text(
          "$label ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: appColors.textSecondary,
            fontSize: isTitle ? 14 : 12,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isTitle ? appColors.gold : appColors.textPrimary,
              fontSize: isTitle ? 16 : 13,
              fontWeight: isTitle ? FontWeight.bold : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
