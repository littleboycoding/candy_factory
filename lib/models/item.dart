import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'item.g.dart';

@HiveType(typeId: 0)
class Item {
  Item({required this.binary, required this.name, required this.description});

  @HiveField(0)
  final Uint8List binary;
  @HiveField(1)
  String name;
  @HiveField(2)
  String description;
}
