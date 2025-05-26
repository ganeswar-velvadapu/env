import 'package:flutter/material.dart';
import 'package:frontend/providers/events_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final storage = const FlutterSecureStorage();

  // Green color palette matching the reports screen
  final primaryGreen = const Color(0xFF2E7D32); // Dark green
  final secondaryGreen = const Color(0xFF4CAF50); // Medium green
  final lightGreen = const Color(0xFFE8F5E9); // Very light green background
  final accentGreen = const Color(0xFF00C853); // Bright green for accents
  final textColor = Colors.black87;

  String title = '';
  String description = '';
  String location = '';
  bool _isSubmitting = false;
  bool _mounted = true;

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTextField(
                  label: 'Title',
                  onChanged: (val) => title = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Title is required' : null,
                  textColor: textColor,
                  primaryGreen: primaryGreen,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Description',
                  onChanged: (val) => description = val,
                  validator: (val) => val == null || val.isEmpty
                      ? 'Description is required'
                      : null,
                  textColor: textColor,
                  primaryGreen: primaryGreen,
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Location',
                  onChanged: (val) => location = val,
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Location is required' : null,
                  textColor: textColor,
                  primaryGreen: primaryGreen,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentGreen,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'SUBMIT EVENT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final token = await storage.read(key: 'token');
    if (token == null) {
      if (!_mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Token missing. Please log in again.'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final eventData = {
      'title': title,
      'description': description,
      'location': location,
    };

    try {
      await context.read<EventsProvider>().addEvent(eventData, token);

      if (!_mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Event added successfully!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );

      _formKey.currentState?.reset();
      setState(() {
        title = '';
        description = '';
        location = '';
        _isSubmitting = false;
      });
      
      // Navigate safely
      if (_mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (!_mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Text('Failed to add event: ${e.toString()}'),
            ],
          ),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    required Color textColor,
    required Color primaryGreen,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: secondaryGreen.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: primaryGreen,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            onChanged: onChanged,
            validator: validator,
            maxLines: maxLines,
            style: TextStyle(color: textColor, fontSize: 16),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }
}