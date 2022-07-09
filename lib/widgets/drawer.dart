import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: const [
          DrawerButton(icon: Icons.home, label: "Home", route: "/"),
          DrawerButton(
              icon: Icons.download, label: "Exports", route: "/exports"),
        ],
      ),
    ));
  }
}

class DrawerButton extends StatelessWidget {
  const DrawerButton(
      {Key? key, required this.icon, required this.label, required this.route})
      : super(key: key);
  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () => Navigator.pushNamed(context, route),
        leading: Icon(icon),
        title: Text(
          label,
          style: const TextStyle(),
        ));
  }
}
