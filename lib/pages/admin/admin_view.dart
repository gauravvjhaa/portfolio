import 'package:flutter/material.dart';

class AdminViewPage extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final List<String> fields;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(String id) onDelete;
  final VoidCallback onAddPressed;

  const AdminViewPage({
    Key? key,
    required this.title,
    required this.items,
    required this.fields,
    required this.onEdit,
    required this.onAddPressed,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            '$title List',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing: ElevatedButton.icon(
            onPressed: onAddPressed,
            icon: const Icon(Icons.add),
            label: const Text('Add'),
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, idx) {
              final item = items[idx];
              return ListTile(
                title: Text(
                  fields.map((f) => item[f]?.toString() ?? '').join(' | '),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => onEdit(item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => onDelete(item['id'].toString()),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
