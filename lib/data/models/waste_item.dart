import 'package:hive/hive.dart';

part 'waste_item.g.dart';

@HiveType(typeId: 1)

class WasteItem extends HiveObject {

  @HiveField(0)
  int id;

  @HiveField(1)
  String file;

  @HiveField(2)
  String wasteType;

  @HiveField(3)
  String qty;

  @HiveField(4)
  List<String> dispose;

  @HiveField(5)
  List<String> dont;

  WasteItem({
    required this.id,
    required this.file,
    required this.wasteType,
    required this.qty,
    required this.dispose,
    required this.dont,
  });
}



