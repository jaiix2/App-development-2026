import 'package:flutter/material.dart';

import 'repository.dart';
import 'folder.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  final Repository repository;

  const FoldersScreen({super.key, required this.repository});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  List<Folder> folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final results = await widget.repository.getFolders();

    setState(() {
      folders = results;
    });
  }

  Future<void> _addFolder() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Folder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Folder name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isNotEmpty) {
                  Navigator.pop(context, value);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (name == null) return;

    await widget.repository.insertFolder(
      Folder(name: name, createdAt: DateTime.now().toIso8601String()),
    );

    await _loadFolders();
  }

  Future<void> _deleteFolder(Folder folder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Folder?'),
          content: Text('Delete "${folder.name}" and all cards inside it?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await widget.repository.deleteFolder(folder.id!);
    await _loadFolders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Folders')),
      floatingActionButton: FloatingActionButton(
        onPressed: _addFolder,
        child: const Icon(Icons.add),
      ),
      body: folders.isEmpty
          ? const Center(child: Text('No folders yet.'))
          : ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];

                return ListTile(
                  title: Text(folder.name),
                  subtitle: Text('${folder.cardCount} card(s)'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteFolder(folder),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CardsScreen(
                          repository: widget.repository,
                          folder: folder,
                        ),
                      ),
                    ).then((_) => _loadFolders());
                  },
                );
              },
            ),
    );
  }
}
