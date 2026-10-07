import 'package:flutter/material.dart';
import 'database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = DatabaseHelper();

  try {
    await db.init();
    runApp(RosterApp(db: db));
  } catch (e) {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Could not open local storage.'),
          ),
        ),
      ),
    );
  }
}

class RosterApp extends StatelessWidget {
  final DatabaseHelper db;

  const RosterApp({super.key, required this.db});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fall Festival Roster',
      home: RosterScreen(db: db),
    );
  }
}

class RosterScreen extends StatefulWidget {
  final DatabaseHelper db;

  const RosterScreen({super.key, required this.db});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();

  List<Map<String, dynamic>> guests = [];
  int? editingId;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadGuests();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<void> loadGuests() async {
    try {
      final data = await widget.db.queryAllRows();

      if (!mounted) return;

      setState(() {
        guests = data;
        loading = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = 'Could not load guests.';
      });
    }
  }

  Future<void> saveGuest() async {
    final name = nameController.text.trim();
    final age = int.tryParse(ageController.text.trim());

    if (name.isEmpty) {
      showMessage('Name cannot be blank.');
      return;
    }

    if (age == null || age < 0 || age > 130) {
      showMessage('Age must be a whole number from 0 to 130.');
      return;
    }

    try {
      if (editingId == null) {
        final id = await widget.db.insert({
          DatabaseHelper.columnName: name,
          DatabaseHelper.columnAge: age,
        });

        showMessage('Guest added. ID: $id');
      } else {
        final result = await widget.db.update({
          DatabaseHelper.columnId: editingId,
          DatabaseHelper.columnName: name,
          DatabaseHelper.columnAge: age,
        });

        if (result != 1) {
          showMessage('Guest was not found.');
          await loadGuests();
          return;
        }

        showMessage('Guest updated.');
      }

      clearForm();
      await loadGuests();
    } catch (e) {
      showMessage('Database operation failed.');
    }
  }

  void editGuest(Map<String, dynamic> guest) {
    setState(() {
      editingId = guest[DatabaseHelper.columnId];
      nameController.text = guest[DatabaseHelper.columnName].toString();
      ageController.text = guest[DatabaseHelper.columnAge].toString();
    });
  }

  void cancelEdit() {
    clearForm();
    showMessage('Edit cancelled.');
  }

  Future<void> deleteGuest(Map<String, dynamic> guest) async {
    final id = guest[DatabaseHelper.columnId] as int;
    final name = guest[DatabaseHelper.columnName].toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Guest?'),
        content: Text('Delete $name (ID $id)?'),
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
      ),
    );

    if (confirmed != true) return;

    try {
      final result = await widget.db.delete(id);

      if (result == 1) {
        if (editingId == id) clearForm();
        showMessage('Guest deleted.');
      } else {
        showMessage('Guest was not found.');
      }

      await loadGuests();
    } catch (e) {
      showMessage('Could not delete guest.');
    }
  }

  void clearForm() {
    nameController.clear();
    ageController.clear();

    setState(() {
      editingId = null;
    });
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final editing = editingId != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fall Festival Roster'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Guests: ${guests.length}',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Guest Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveGuest,
                child: Text(editing ? 'Save Changes' : 'Add Guest'),
              ),
            ),

            if (editing)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: cancelEdit,
                  child: const Text('Cancel Edit'),
                ),
              ),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: loadGuests,
                child: const Text('Refresh'),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error != null
                      ? Center(child: Text(error!))
                      : guests.isEmpty
                          ? const Center(
                              child: Text('No festival guests yet.'),
                            )
                          : ListView.builder(
                              itemCount: guests.length,
                              itemBuilder: (context, index) {
                                final guest = guests[index];
                                final id =
                                    guest[DatabaseHelper.columnId];
                                final name =
                                    guest[DatabaseHelper.columnName];
                                final age =
                                    guest[DatabaseHelper.columnAge];

                                return Card(
                                  child: ListTile(
                                    title: Text('$name'),
                                    subtitle: Text(
                                      'ID: $id  •  Age: $age',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          onPressed: () =>
                                              editGuest(guest),
                                          icon: const Icon(Icons.edit),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              deleteGuest(guest),
                                          icon: const Icon(Icons.delete),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}