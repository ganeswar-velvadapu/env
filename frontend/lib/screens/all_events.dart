import 'package:flutter/material.dart';
import 'package:frontend/providers/events_provider.dart';
import 'package:provider/provider.dart';
import 'package:frontend/models/event.dart';

class AllEventsScreen extends StatefulWidget {
  const AllEventsScreen({super.key});

  @override
  State<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends State<AllEventsScreen> {
  // Green color palette matching the reports screen
  final primaryGreen = const Color(0xFF2E7D32); // Dark green
  final secondaryGreen = const Color(0xFF4CAF50); // Medium green
  final lightGreen = const Color(0xFFE8F5E9); // Very light green background
  final accentGreen = const Color(0xFF00C853); // Bright green for accents
  final textColor = Colors.black87;
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    await context.read<EventsProvider>().fetchEvents();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventsProvider>().events;

    return Scaffold(
      backgroundColor: lightGreen,
      body: _isLoading
          ? Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: primaryGreen,
                ),
              ),
            )
          : events.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        color: secondaryGreen,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No events found',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check back later for upcoming events',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: primaryGreen,
                  onRefresh: _loadEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final Event event = events[index];
                      return Card(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: secondaryGreen.withOpacity(0.3),
                          ),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.event,
                                    color: primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      event.title.isNotEmpty
                                          ? event.title
                                          : "(No Title)",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                event.description.isNotEmpty
                                    ? event.description
                                    : "(No Description)",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withOpacity(0.8),
                                  height: 1.5,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: secondaryGreen,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "Location: ${event.location}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: textColor.withOpacity(0.6),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    color: secondaryGreen,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      "Posted by: ${event.ngoEmail}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: textColor.withOpacity(0.6),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              // if (event.date != null) ...[
                              //   const SizedBox(height: 8),
                              //   Row(
                              //     children: [
                              //       Icon(
                              //         Icons.calendar_today_outlined,
                              //         color: secondaryGreen,
                              //         size: 16,
                              //       ),
                              //       const SizedBox(width: 4),
                              //       // Text(
                              //       //   "Date: ${event.date!.toLocal().toString().split(' ')[0]}",
                              //       //   style: TextStyle(
                              //       //     fontSize: 13,
                              //       //     color: textColor.withOpacity(0.6),
                              //       //   ),
                              //       // ),
                              //     ],
                              //   ),
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