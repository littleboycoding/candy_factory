import 'package:file_picker/file_picker.dart';
import "package:flutter/material.dart";
import 'package:hive_flutter/hive_flutter.dart';

import '../widgets/drawer.dart';
import '../models/item.dart';
import '../widgets/items_list.dart';

class Home extends StatelessWidget {
  Home({super.key});

  final _itemsBox = Hive.box<Item>("items");

  void pick() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.image,
    );

    if (result != null) {
      for (PlatformFile file in result.files) {
        final bytes = file.bytes;
        if (bytes == null) continue;

        _itemsBox.add(Item(
          binary: bytes,
          name: file.name,
          description: "",
        ));
      }
    }
  }

  void clear() {
    _itemsBox.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Candy Factory 🍭")),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: pick,
        child: const Icon(Icons.add_box),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: ValueListenableBuilder<Box<Item>>(
          valueListenable: _itemsBox.listenable(),
          builder: (context, itemsBox, child) => ItemList(
            itemsBox: itemsBox,
            onItemTap: (int itemKey) {
              Navigator.pushNamed(
                context,
                "/item-info",
                arguments: itemKey,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ItemList extends StatelessWidget {
  const _ItemList({required this.itemsBox});

  final Box<Item> itemsBox;

  Widget itemBuilder(BuildContext context, int index) {
    final key = itemsBox.keyAt(index);
    final item = itemsBox.getAt(index)!;

    return ListTile(
        title: Text(item.name),
        subtitle: Text("#$key"),
        onTap: () => Navigator.pushNamed(context, "/item-info", arguments: key),
        leading: Hero(
          tag: key,
          child: CircleAvatar(foregroundImage: MemoryImage(item.binary)),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemBuilder: itemBuilder,
      separatorBuilder: (context, i) => const Divider(),
      itemCount: itemsBox.length,
    );
  }
}
