import 'package:frontend/api/event_api.dart';
import 'package:flutter/material.dart';
import 'package:frontend/models/event.dart';

class EventsProvider with ChangeNotifier {
  List<Event> _events = [];

  List<Event> get events => _events;

  Future<void> fetchEvents() async {
    try {
      final response = await EventApi.getAllEvents();
      print(response);
      if (response.data is Map<String, dynamic>) {
        final fetchedEvents = response.data['fetched_all'];

        if (fetchedEvents is List) {
          _events =
              fetchedEvents.map((reportData) {
                return Event.fromJson(reportData);
              }).toList();
        }
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching events: $e");
    }
  }

  Future<void> addEvent(Map<String, dynamic> eventData, String token) async {
    try {
      final response = await EventApi.addEvent(eventData, token);
      print(response);
      await fetchEvents();
    } catch (e) {
      print("Error adding event: $e");
    }
  }

  Future<void> editEvent(
    Map<String, dynamic> eventData,
    String token,
    int id,
  ) async {
    try {
      final response = await EventApi.editEvent(eventData, token, id);
      print(response);
      await fetchEvents();
    } catch (e) {
      print("Error editing event: $e");
    }
  }

  Future<void> deleteEvent(int id, String token) async {
    try {
      final response = await EventApi.deleteEvent(token, id);
      print(response);
      await fetchEvents();
    } catch (e) {
      print("Error deleting event: $e");
    }
  }
}
