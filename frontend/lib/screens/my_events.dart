import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:frontend/providers/events_provider.dart';
import 'package:frontend/models/event.dart';

class MyEvents extends StatefulWidget {
  const MyEvents({super.key});

  @override
  State<MyEvents> createState() => _MyEventsState();
}

class _MyEventsState extends State<MyEvents> {
  final _storage = const FlutterSecureStorage();
  bool _isLoading = true;

  final primaryGreen = const Color(0xFF2E7D32);
  final secondaryGreen = const Color(0xFF4CAF50);
  final lightGreen = const Color(0xFFE8F5E9);
  final accentGreen = const Color(0xFF00C853);
  final textColor = Colors.black87;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      print("Token not found");
      return;
    }

    await context.read<EventsProvider>().fetchNgoEvents(token);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showEditDialog(Event event) {
    final titleController = TextEditingController(text: event.title);
    final descController = TextEditingController(text: event.description);
    final locationController = TextEditingController(text: event.location);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Edit Event", style: TextStyle(color: primaryGreen)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final token = await _storage.read(key: 'token');
                  if (token == null) {
                    print("Token not found");
                    return;
                  }

                  final updatedEvent = {
                    'title': titleController.text,
                    'description': descController.text,
                    'location': locationController.text,
                  };

                  await context.read<EventsProvider>().editEvent(
                    updatedEvent,
                    token,
                    event.id,
                  );

                  if (mounted) Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }

  void _onDelete(int id) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      print("Token not found");
      return;
    }

    await context.read<EventsProvider>().deleteEvent(id, token);
  }

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventsProvider>().events;

    return Scaffold(
      backgroundColor: lightGreen.withOpacity(0.5),
     
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryGreen))
              : events.isEmpty
              ? Center(
                child: Text(
                  "No events found.",
                  style: TextStyle(color: textColor, fontSize: 16),
                ),
              )
              : RefreshIndicator(
                color: primaryGreen,
                onRefresh: _loadEvents,
                child: ListView.builder(
                  itemCount: events.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.event, color: primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    event.title,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              event.description,
                              style: TextStyle(
                                color: textColor.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: secondaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  event.location,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showEditDialog(event),
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: primaryGreen,
                                  ),
                                  label: Text(
                                    "Edit",
                                    style: TextStyle(color: primaryGreen),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: () => _onDelete(event.id),
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  label: const Text(
                                    "Delete",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
