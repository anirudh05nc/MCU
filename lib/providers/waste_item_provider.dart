import 'package:hive_flutter/hive_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/models/waste_item.dart';

part 'waste_item_provider.g.dart';

@riverpod
class WasteItemList extends _$WasteItemList {
  // 1. The build method initializes the state
  @override
  Future<List<WasteItem>> build() async {
    // Open the box. It's best practice to give the box a specific name.
    final box = await Hive.openBox<WasteItem>('waste_items');

    // Return the values as a list.
    // We convert values to a List so Riverpod can handle it easily.
    return box.values.toList();
  }

  // 2. Add a method to add items (Optional but likely needed)
  Future<void> addWasteItem(WasteItem item) async {
    final box = Hive.box<WasteItem>('waste_items');
    // Add to Hive
    await box.add(item);
    ref.invalidateSelf();
  }

  // 3. Add a method to delete items (Optional)
  Future<void> deleteWasteItem(WasteItem item) async {
    // Since WasteItem extends HiveObject, it has a handy delete() method
    await item.delete();

    // Refresh the state
    ref.invalidateSelf();
  }
}
