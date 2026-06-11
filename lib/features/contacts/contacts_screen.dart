import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../shared/models/user_model.dart';

class ContactsScreen extends StatefulWidget {
  final List<TrustedContact> contacts;
  final ValueChanged<List<TrustedContact>> onChanged;

  const ContactsScreen({
    super.key,
    required this.contacts,
    required this.onChanged,
  });

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late List<TrustedContact> _contacts;

  @override
  void initState() {
    super.initState();
    _contacts = List.from(widget.contacts);
  }

  void _remove(int index) {
    setState(() => _contacts.removeAt(index));
    widget.onChanged(_contacts);
  }

  Future<void> _showAddDialog() async {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final roleCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Trusted Contact'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: '+213 xxx xxx xxx',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: roleCtrl,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                hintText: 'Mother, Friend, Husband...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
              setState(() {
                _contacts.add(TrustedContact(
                  name: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                  role: roleCtrl.text.trim().isEmpty
                      ? 'Contact'
                      : roleCtrl.text.trim(),
                ));
              });
              widget.onChanged(_contacts);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trusted Contacts')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SW.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: SW.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All contacts are notified simultaneously when an alert fires. '
                    'The first to respond closes the active alert for others.',
                    style: TextStyle(
                      color: SW.primary.withAlpha(204),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _contacts.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No contacts yet',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Add people who will be alerted in emergencies',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _contacts.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex--;
                        final item = _contacts.removeAt(oldIndex);
                        _contacts.insert(newIndex, item);
                      });
                      widget.onChanged(_contacts);
                    },
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      return Card(
                        key: ValueKey(contact.phone),
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                SW.surfaceContainerHigh,
                            child: Text(
                              contact.name[0].toUpperCase(),
                              style: TextStyle(
                                color: SW.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            contact.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${contact.role} · ${contact.phone}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: SW.primary.withAlpha(25),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '#${index + 1}',
                                  style: TextStyle(
                                    color: SW.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _remove(index),
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
      floatingActionButton: _contacts.length < 5
          ? FloatingActionButton.extended(
              onPressed: _showAddDialog,
              backgroundColor: SW.primary,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'Add Contact',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}
