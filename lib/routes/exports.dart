import 'dart:convert';
import "dart:io";

import 'package:candy_factory/models/metadata.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/item.dart';
import "../models/exported.dart";
import '../widgets/items_list.dart';
import "../utils/pinata.dart";

class PinataModel {
  PinataModel({this.jwt = ""});

  String jwt;
}

abstract class Method {
  Method({required this.method});

  final String method;
  final _formKey = GlobalKey<FormState>();

  Future<List<Exported>> export(Box<Item> itemsBox) async {
    final state = _formKey.currentState!;
    final items = <Exported>[];

    if (state.validate()) {
      state.save();
      items.addAll(await _export(itemsBox));
    }

    return items;
  }

  Future<List<Exported>> _export(Box<Item> itemsBox);
  Form formBuilder();
}

class PinataMethod extends Method {
  PinataMethod() : super(method: "Pinata");

  final _formData = PinataModel();

  String createIpfsUri(String hash) => "https://dweb.link/ipfs/$hash";

  @override
  Future<List<Exported>> _export(Box<Item> itemsBox) async {
    final pinata = Pinata(jwt: _formData.jwt);
    final items = <Exported>[];

    for (int itemKey in itemsBox.keys) {
      final item = itemsBox.get(itemKey)!;

      final metadata = await pinata
          .pinFileToIPFS(
            item.binary,
            item.name,
          )
          .then(
            (res) => Metadata(
              name: item.name,
              description: item.description,
              image: createIpfsUri(res.ipfsHash),
            ),
          );

      final metadataUri = await pinata
          .pinJSONToIPFS(
            metadata,
            "${item.name}_metadata.json",
          )
          .then((res) => createIpfsUri(res.ipfsHash));

      items.add(
        Exported(
          id: itemKey,
          uris: metadataUri,
        ),
      );
    }

    pinata.close();

    return items;
  }

  @override
  Form formBuilder() {
    return Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              validator: (value) => value == "" ? "Must not be empty" : null,
              onSaved: (value) {
                if (value != null) _formData.jwt = value;
              },
              decoration: const InputDecoration(
                labelText: "Pinata JWT",
              ),
            ),
          ],
        ));
  }
}

class Exports extends StatefulWidget {
  const Exports({super.key});

  static final methods = <Method>[
    PinataMethod(),
  ];

  @override
  State<Exports> createState() => _ExportsState();
}

class _ExportsState extends State<Exports> {
  final _itemsBox = Hive.box<Item>("items");

  var _method = Exports.methods.first;
  var _exporting = false;

  void showSnackBar(Widget widget) {
    final snackBar = SnackBar(
      content: widget,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      snackBar,
    );
  }

  void export() async {
    setState(() {
      _exporting = true;
    });

    final path = await FilePicker.platform.saveFile(
      fileName: "exported.json",
    );

    if (path != null) {
      try {
        final items = await _method.export(_itemsBox);

        showSnackBar(const Text("Export successfully !"));

        final json = jsonEncode(items);

        await File(path).writeAsString(json);
      } catch (e) {
        if (e is PinError) {
          showSnackBar(Text("Error occured: ${e.message}"));
        } else {
          rethrow;
        }
      }
    }

    setState(() {
      _exporting = false;
    });
  }

  DropdownButton<Method> methodSelectionBuilder() {
    return DropdownButton(
      isExpanded: true,
      items: [
        for (Method method in Exports.methods)
          DropdownMenuItem(
            value: method,
            child: Text(method.method),
          )
      ],
      onChanged: (Method? method) {
        if (method != null) _method = method;
      },
      value: _method,
    );
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.all(16);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Exports"),
      ),
      body: Container(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Card(
              child: Padding(
                padding: padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    methodSelectionBuilder(),
                    _method.formBuilder(),
                    const SizedBox(height: 16),
                    _exporting
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: export,
                            child: const Text("Exports"),
                          ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ItemList(
                itemsBox: _itemsBox,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
