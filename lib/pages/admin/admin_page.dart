import 'package:flutter/material.dart';
import 'admin_view.dart';
import 'admin_edit.dart';
import 'admin_add.dart';

// Example: how you might store which table and data to display/edit
enum AdminSection { skills, projects, certificates }

class AdminPage extends StatefulWidget {
  final String token; // Pass token from login screen
  const AdminPage({Key? key, required this.token}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  AdminSection _section = AdminSection.skills;

  // Mimic server data (you'd fetch from API in real use)
  List<Map<String, dynamic>> _items = [];
  Map<String, dynamic>? _editingItem;
  bool _isAdding = false;

  // Example table configs
  String get _sectionTitle {
    switch (_section) {
      case AdminSection.skills:
        return 'Skills';
      case AdminSection.projects:
        return 'Projects';
      case AdminSection.certificates:
        return 'Certificates';
    }
  }

  List<String> get _fields {
    switch (_section) {
      case AdminSection.skills:
        return ['name', 'category', 'proficiency'];
      case AdminSection.projects:
        return ['title', 'description', 'tags'];
      case AdminSection.certificates:
        return ['name', 'authority', 'issue_date'];
    }
  }

  // Simulate fetch
  void _loadData() {
    // Replace with API call, using widget.token for authentication
    setState(() {
      _editingItem = null;
      _isAdding = false;
      _items = [
        if (_section == AdminSection.skills)
          {
            'id': '1',
            'name': 'Flutter',
            'category': 'Frontend',
            'proficiency': '90',
          },
        if (_section == AdminSection.projects)
          {
            'id': '2',
            'title': 'Personal Site',
            'description': 'Portfolio',
            'tags': 'flutter,web',
          },
        if (_section == AdminSection.certificates)
          {
            'id': '3',
            'name': 'Flutter Developer',
            'authority': 'Google',
            'issue_date': '2024-05-01',
          },
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _onEdit(Map<String, dynamic> item) {
    setState(() {
      _editingItem = item;
      _isAdding = false;
    });
  }

  void _onAdd() {
    setState(() {
      _editingItem = null;
      _isAdding = true;
    });
  }

  void _onSaveEdit(Map<String, dynamic> updated) {
    // Replace with PATCH/PUT API call; use widget.token
    setState(() {
      _editingItem = null;
      _isAdding = false;
      int index = _items.indexWhere((e) => e['id'] == updated['id']);
      if (index != -1) _items[index] = updated;
    });
  }

  void _onSaveAdd(Map<String, dynamic> added) {
    // Replace with POST API call; use widget.token
    setState(() {
      _editingItem = null;
      _isAdding = false;
      _items.add({
        ...added,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      });
    });
  }

  void _onCancel() {
    setState(() {
      _editingItem = null;
      _isAdding = false;
    });
  }

  void _onDelete(String id) {
    // Replace with DELETE API call; use widget.token
    setState(() {
      _items.removeWhere((e) => e['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isAdding) {
      body = AdminAddPage(
        title: _sectionTitle,
        fields: _fields,
        onAdd: (data) {
          _onSaveAdd(data);
        },
        onCancel: _onCancel,
      );
    } else if (_editingItem != null) {
      body = AdminEditPage(
        title: _sectionTitle,
        fields: _fields,
        item: _editingItem!,
        onSave: (data) {
          _onSaveEdit(data);
        },
        onCancel: _onCancel,
      );
    } else {
      body = AdminViewPage(
        title: _sectionTitle,
        items: _items,
        fields: _fields,
        onEdit: _onEdit,
        onAddPressed: _onAdd,
        onDelete: _onDelete,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          PopupMenuButton<AdminSection>(
            onSelected: (section) {
              setState(() {
                _section = section;
                _loadData();
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: AdminSection.skills,
                    child: Text('Skills'),
                  ),
                  const PopupMenuItem(
                    value: AdminSection.projects,
                    child: Text('Projects'),
                  ),
                  const PopupMenuItem(
                    value: AdminSection.certificates,
                    child: Text('Certificates'),
                  ),
                ],
          ),
        ],
      ),
      body: body,
    );
  }
}
