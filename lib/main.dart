import 'package:flutter/material.dart';
import "package:hive_flutter/hive_flutter.dart";

import 'routes/exports.dart';
import 'routes/home.dart';
import 'routes/item_info.dart';
import "models/item.dart";

void main() async {
  Hive.registerAdapter(ItemAdapter());

  await Hive.initFlutter();
  await Hive.openBox<Item>("items");

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Candy Factory',
      home: Home(),
      routes: {
        "/exports": (context) => const Exports(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/item-info":
            return MaterialPageRoute(
              builder: (context) => ItemInfo(settings.arguments as int),
            );
          default:
            return null;
        }
      },
    );
  }
}
