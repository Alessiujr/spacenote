import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> sections = [
    {"name": "Home", "icon": "🏠"}
  ];

  String selectedSection = "Home";

  void _showAddSectionDialog() {
    final nameController = TextEditingController();
    String selectedIcon = "🏠";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Aggiungi sezione"),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Nome sezione",
                ),
              ),
              const SizedBox(height: 15),

              DropdownButton<String>(
                value: selectedIcon,
                items: ["🏠", "🚗", "🛵", "📂"]
                    .map((icon) => DropdownMenuItem(
                          value: icon,
                          child: Text(icon),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    selectedIcon = value;
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annulla"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    sections.add({
                      "name": nameController.text,
                      "icon": selectedIcon
                    });
                    selectedSection = nameController.text;
                  });

                  Navigator.pop(context);

                  /// Popup Space Created
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✨ Space Created"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text("Salva"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      /// ✅ MENU A SINISTRA
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(25),
                bottomRight: Radius.circular(25))),

        child: ListView(
          padding: const EdgeInsets.all(20),
          children: sections.map((section) {
            return ListTile(
              leading: Text(section["icon"]!),
              title: Text(section["name"]!),
              onTap: () {
                setState(() {
                  selectedSection = section["name"]!;
                });
                Navigator.pop(context);
              },
            );
          }).toList()
            ..add(
              ListTile(
                leading: const Text("➕"),
                title: const Text("Aggiungi sezione"),
                onTap: () {
                  Navigator.pop(context);
                  _showAddSectionDialog();
                },
              ),
            ),
        ),
      ),

      /// APPBAR MODERNO
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          selectedSection,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),

      body: Center(
        child: Text(
          "Sezione: $selectedSection",
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}