import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';
import 'space_detail_page.dart';
import '../models/event_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> sections = [
    {
      "name": "Home",
      "icon": "🏠",
      "events": [],
    }
  ];

  String selectedSection = "Home";

  final List<String> availableIcons = [
    "🏠",
    "🚗",
    "🛵",
    "📂",
    "✈️",
    "💡",
    "📌",
    "🧾"
  ];

  @override
  void initState() {
    super.initState();
    _loadSections();
  }

  /// Load storage
  void _loadSections() async {
    final data = await LocalStorageService.loadSections();

    if (data.isNotEmpty) {
      setState(() {
        sections = List<Map<String, dynamic>>.from(data);
        selectedSection = sections.first["name"];
      });
    }
  }

  /// Save storage helper
  Future<void> _saveSections() async {
    await LocalStorageService.saveSections(
      sections.map((e) {
        return e.map((key, value) => MapEntry(key, value.toString()));
      }).toList(),
    );
  }

  /// Add space dialog
  void _showAddSectionDialog() {
    final nameController = TextEditingController();
    String selectedIcon = availableIcons.first;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add Space"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Space name"),
                  ),
                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 10,
                    children: availableIcons.map((icon) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedIcon = icon;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedIcon == icon
                                  ? Colors.deepPurple
                                  : Colors.grey,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(icon,
                              style: const TextStyle(fontSize: 20)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;

                    setState(() {
                      sections.add({
                        "name": nameController.text,
                        "icon": selectedIcon,
                        "events": [],
                      });

                      selectedSection = nameController.text;
                    });

                    await _saveSections();

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✨ Space Created"),
                      ),
                    );
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Drawer UI
  Widget _buildDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...sections.map((section) {
            return ListTile(
              selected: selectedSection == section["name"],
              selectedTileColor: Colors.deepPurple.withOpacity(0.1),
              leading: Text(section["icon"] ?? "📌"),
              title: Text(section["name"]),

              onTap: () {
                Navigator.pop(context);

                setState(() {
                  selectedSection = section["name"];
                });

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpaceDetailPage(
                      spaceName: section["name"],
                      events: (section["events"] ?? [])
                          .map<EventModel>((e) =>
                              EventModel.fromJson(
                                  Map<String, dynamic>.from(e)))
                          .toList(),
                    ),
                  ),
                );
              },

              onLongPress: () async {
                if (section["name"] == "Home") return;

                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Delete Space"),
                    content: const Text(
                        "Are you sure you want to delete this space?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          setState(() {
                            sections.removeWhere(
                                (e) => e["name"] == section["name"]);
                          });

                          await _saveSections();

                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),

          const Divider(),

          ListTile(
            leading: const Text("➕"),
            title: const Text("Add Space"),
            onTap: () {
              Navigator.pop(context);
              _showAddSectionDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return const Center(
      child: Text(
        "Select a Space from drawer",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: _buildDrawer(),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),

        title: const Text(
          "Spacenote",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: _buildBody(),

      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSectionDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}