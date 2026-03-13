import 'package:flutter/material.dart';

class AdminEditPage extends StatefulWidget {
  final String title;
  final List<String> fields;
  final Map<String, dynamic> item;
  final void Function(Map<String, dynamic>) onSave;
  final VoidCallback onCancel;

  const AdminEditPage({
    Key? key,
    required this.title,
    required this.fields,
    required this.item,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<AdminEditPage> createState() => _AdminEditPageState();
}

class _AdminEditPageState extends State<AdminEditPage> {
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = {
      for (final f in widget.fields)
        f: TextEditingController(text: widget.item[f]?.toString() ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.title}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: widget.onCancel,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...widget.fields.map(
            (field) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                controller: controllers[field],
                decoration: InputDecoration(labelText: field.capitalize()),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save'),
            onPressed: () {
              final updated = <String, dynamic>{
                ...widget.item,
                for (final f in widget.fields) f: controllers[f]!.text,
              };
              widget.onSave(updated);
            },
          ),
        ],
      ),
    );
  }
}

extension on String {
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
