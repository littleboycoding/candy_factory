import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../widgets/thumbnail.dart';
import '../models/metadata.dart';
import '../models/item.dart';

class ItemInfo extends StatefulWidget {
  const ItemInfo(this.itemKey, {super.key});
  final int itemKey;

  @override
  State<ItemInfo> createState() => _ItemInfoState();
}

class _ItemInfoController {
  _ItemInfoController({String? id, String? name, String? description})
      : id = TextEditingController(text: id),
        name = TextEditingController(text: name),
        description = TextEditingController(text: description);

  final TextEditingController id;
  final TextEditingController name;
  final TextEditingController description;
}

class _ItemInfoState extends State<ItemInfo> {
  static const _tabs = [
    Tab(icon: Icon(Icons.info), text: "Information"),
    Tab(icon: Icon(Icons.code), text: "Metadata"),
  ];

  late final _ItemInfoController _controller;
  late Item _item;

  final _itemBox = Hive.box<Item>("items");

  int get _itemKey => widget.itemKey;

  @override
  void initState() {
    super.initState();
    _item = _itemBox.get(widget.itemKey)!;

    _controller = _ItemInfoController(
        id: _itemKey.toString(),
        name: _item.name,
        description: _item.description);
  }

  void save() {
    setState(() {
      _item = Item(
        binary: _item.binary,
        description: _controller.description.text,
        name: _controller.name.text,
      );
    });

    _itemBox.put(_itemKey, _item).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Item has been saved"),
      ));
    });
  }

  void reset() {
    _controller.name.text = _item.name;
    _controller.description.text = _item.description;
  }

  void delete() {
    _itemBox.delete(_itemKey);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text("${_item.name} #$_itemKey"),
          bottom: const TabBar(tabs: _tabs),
        ),
        body: TabBarView(
          children: [
            _InformationView(
              heroTag: _itemKey,
              item: _item,
              controller: _controller,
              onReset: reset,
              onSave: save,
              onDelete: delete,
            ),
            _MetadataView(
              metadata: Metadata(
                name: _item.name,
                description: _item.description,
                image: "IMAGE_URI",
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _MetadataView extends StatelessWidget {
  const _MetadataView({required this.metadata});

  final Metadata metadata;

  void copy(BuildContext context) {
    final data = ClipboardData(text: _properties);

    Clipboard.setData(data).then((v) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Copied to clipboard"),
        ),
      );
    });
  }

  String get _properties {
    final metadata = this.metadata.toJson();
    final prop = [
      for (String prop in metadata.keys) '  "$prop": "${metadata[prop]}"'
    ].join(",\n");

    return "{\n$prop\n}";
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontFamily: "monospace",
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(_properties),
            const Divider(),
            ButtonBar(
              children: [
                IconButton(
                  onPressed: () => copy(context),
                  icon: const Icon(Icons.copy),
                  tooltip: "Copy to clipboard",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationView extends StatelessWidget {
  const _InformationView({
    required this.heroTag,
    required this.item,
    required this.controller,
    this.onReset,
    this.onSave,
    this.onDelete,
  });

  final int heroTag;
  final Item item;
  final _ItemInfoController controller;
  final Function()? onReset;
  final Function()? onSave;
  final Function()? onDelete;

  List<Widget> get _controls => [
        IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete),
            tooltip: "Delete"),
        IconButton(
            onPressed: onReset,
            icon: const Icon(Icons.restore),
            tooltip: "Reset"),
        IconButton(
            onPressed: onSave, icon: const Icon(Icons.save), tooltip: "Save")
      ];

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Thumbnail(heroTag: heroTag, binary: item.binary),
      Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Column(
                children: [
                  TextField(
                    controller: controller.id,
                    enabled: false,
                    decoration: const InputDecoration(
                      label: Text("Id"),
                    ),
                  ),
                  TextField(
                    controller: controller.name,
                    decoration: const InputDecoration(
                      label: Text("Name"),
                    ),
                  ),
                  TextField(
                    controller: controller.description,
                    decoration: const InputDecoration(
                      label: Text("Description"),
                    ),
                  ),
                ],
              ),
              ButtonBar(children: _controls)
            ],
          ))
    ]);
  }
}
