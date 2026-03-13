import 'package:flutter/material.dart';

class AdminAddPage extends StatefulWidget {
  final String title;
  final List<String> fields;
  final void Function(Map<String, dynamic>) onAdd;
  final VoidCallback onCancel;

  const AdminAddPage({
    Key? key,
    required this.title,
    required this.fields,
    required this.onAdd,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<AdminAddPage> createState() => _AdminAddPageState();
}

class _AdminAddPageState extends State<AdminAddPage> {
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = {for (final f in widget.fields) f: TextEditingController()};
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
        title: Text('Add ${widget.title}'),
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
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            onPressed: () {
              final data = <String, dynamic>{
                for (final f in widget.fields) f: controllers[f]!.text,
              };
              widget.onAdd(data);
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
