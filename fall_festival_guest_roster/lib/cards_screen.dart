import 'package:flutter/material.dart';

import 'repository.dart';
import 'folder.dart';
import 'card_model.dart';

class CardsScreen extends StatefulWidget {
  final Repository repository;
  final Folder folder;

  const CardsScreen({
    super.key,
    required this.repository,
    required this.folder,
  });

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  List<CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final results = await widget.repository.getCards(widget.folder.id!);

    if (!mounted) return;

    setState(() => cards = results);
  }

  Future<void> _showError(String message) async {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _addCard() async {
    final result = await _showCardDialog();

    if (result == null) return;

    try {
      await widget.repository.insertCard(
        CardModel(
          title: result['title']!,
          suit: result['suit']!,
          notes: result['notes']!,
          folderId: widget.folder.id!,
        ),
      );

      await _loadCards();
    } catch (_) {
      await _showError('Could not add card.');
    }
  }

  Future<void> _editCard(CardModel card) async {
    final result = await _showCardDialog(card: card);

    if (result == null) return;

    try {
      await widget.repository.updateCard(
        CardModel(
          id: card.id,
          title: result['title']!,
          suit: result['suit']!,
          notes: result['notes']!,
          imageRef: card.imageRef,
          folderId: card.folderId,
        ),
      );

      await _loadCards();
    } catch (_) {
      await _showError('Could not update card.');
    }
  }

  Future<Map<String, String>?> _showCardDialog({CardModel? card}) async {
    // The dialog owns these controllers and disposes them
    // only after its TextFormFields are removed.
    return showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _CardDialog(card: card),
    );
  }

  Future<void> _deleteCard(CardModel card) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Card?'),
        content: Text('Delete "${card.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await widget.repository.deleteCard(card.id!);
      await _loadCards();
    } catch (_) {
      await _showError('Could not delete card.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.folder.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        tooltip: 'Add card',
        child: const Icon(Icons.add),
      ),
      body: cards.isEmpty
          ? const Center(child: Text('No cards in this folder.'))
          : ListView.builder(
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];

                return ListTile(
                  leading: const Icon(Icons.style),
                  title: Text(card.title),
                  subtitle: Text('${card.suit}\n${card.notes}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        tooltip: 'Edit card',
                        onPressed: () => _editCard(card),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete card',
                        onPressed: () => _deleteCard(card),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _CardDialog extends StatefulWidget {
  final CardModel? card;

  const _CardDialog({this.card});

  @override
  State<_CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<_CardDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _notesController;
  final _formKey = GlobalKey<FormState>();

  late String _suit;

  static const _suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.card?.title ?? '');

    _notesController = TextEditingController(text: widget.card?.notes ?? '');

    _suit = _suits.contains(widget.card?.suit) ? widget.card!.suit : 'Hearts';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.card == null ? 'Add Card' : 'Edit Card'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _suit,
                decoration: const InputDecoration(labelText: 'Suit'),
                items: _suits.map((suit) {
                  return DropdownMenuItem(value: suit, child: Text(suit));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _suit = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            Navigator.pop(context, {
              'title': _titleController.text.trim(),
              'suit': _suit,
              'notes': _notesController.text.trim(),
            });
          },
          child: Text(widget.card == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
