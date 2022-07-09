import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/item.dart';

class ItemList extends StatelessWidget {
  const ItemList({super.key, required this.itemsBox, this.onItemTap});

  final Box<Item> itemsBox;
  final void Function(int)? onItemTap;

  Widget itemBuilder(BuildContext context, int index) {
    final itemKey = itemsBox.keyAt(index);
    final item = itemsBox.getAt(index)!;

    final onTap = onItemTap != null ? () => onItemTap!(itemKey) : null;

    return ListTile(
      leading: CircleAvatar(foregroundImage: MemoryImage(item.binary)),
      title: Text(item.name),
      subtitle: Text("#$itemKey"),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemBuilder: itemBuilder,
      separatorBuilder: (context, index) => const Divider(),
      itemCount: itemsBox.length,
    );
  }
}
