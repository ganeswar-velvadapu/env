import 'package:flutter/material.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '', description = '', location = '';
  String status = 'PENDING';
  bool _isGettingLocation = true;
  bool _isSubmitting = false;

  // Green color palette for app theme
  final primaryGreen = const Color(0xFF2E7D32); // Dark green
  final secondaryGreen = const Color(0xFF4CAF50); // Medium green
  final lightGreen = const Color(0xFFE8F5E9); // Very light green background
  final accentGreen = const Color(0xFF00C853); // Bright green for accents

  final storage = FlutterSecureStorage();

  final List<String> statusOptions = ['PENDING', 'RESPONDED'];

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        List<Placemark> placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;
          final address =
              '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
          setState(() {
            location = address;
            _isGettingLocation = false;
          });
        } else {
          setState(() {
            location = 'Unknown location';
            _isGettingLocation = false;
          });
        }
      } else {
        setState(() {
          location = 'Permission denied';
          _isGettingLocation = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        location = 'Location unavailable';
        _isGettingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.read<ReportProvider>();
    final textColor = Colors.grey[800] ?? Colors.black87;

    return Container(
      color: lightGreen.withOpacity(0.5),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Form fields with animations
                _buildTextField(
                      label: 'Title',
                      hint: 'Enter report title',
                      onChanged: (val) => title = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Title is required'
                                  : null,
                      textColor: textColor,
                      prefixIcon: Icons.title,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 100.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: 16),

                _buildTextField(
                      label: 'Description',
                      hint: 'Enter detailed description',
                      onChanged: (val) => description = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Description is required'
                                  : null,
                      textColor: textColor,
                      maxLines: 3,
                      prefixIcon: Icons.description_outlined,
                    )
                    .animate()
                    .fade(duration: 400.ms, delay: 200.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: 16),

                _buildStatusDropdown(textColor)
                    .animate()
                    .fade(duration: 400.ms, delay: 300.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: 16),

                _buildLocationField(textColor)
                    .animate()
                    .fade(duration: 400.ms, delay: 400.ms)
                    .slideX(begin: -0.1, end: 0),

                const SizedBox(height: 32),

                _buildSubmitButton(context, reportProvider, textColor)
                    .animate()
                    .fade(duration: 600.ms, delay: 500.ms)
                    .scale(begin: Offset(0.95, 0.95)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    required String? Function(String?) validator,
    required Color? textColor,
    String? hint,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(prefixIcon, size: 16, color: primaryGreen),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextFormField(
            style: TextStyle(color: textColor ?? Colors.black87, fontSize: 16),
            onChanged: onChanged,
            validator: validator,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
              contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              border: InputBorder.none,
              errorStyle: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(Color? textColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, size: 16, color: primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Status',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: status,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: primaryGreen),
                onChanged: (String? newValue) {
                  setState(() {
                    status = newValue!;
                  });
                },
                items:
                    statusOptions.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 4,
                          ),
                          child: Text(
                            value,
                            style: TextStyle(
                              color: textColor ?? Colors.black87,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField(Color? textColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 8,
            ),
            child: Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: primaryGreen),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: TextStyle(
                    color: primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child:
                _isGettingLocation
                    ? Center(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Getting your location...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : Text(
                      location,
                      style: TextStyle(
                        color: textColor ?? Colors.black87,
                        fontSize: 16,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    ReportProvider reportProvider,
    Color? textColor,
  ) {
    final isDisabled = _isSubmitting || _isGettingLocation;

    return GestureDetector(
      onTap:
          isDisabled
              ? null
              : () async {
                if (_formKey.currentState!.validate()) {
                  if (location == 'Permission denied' ||
                      location == 'Unknown location' ||
                      location == 'Location unavailable') {
                    _showErrorSnackBar(
                      context,
                      'Location permission is required to submit a report.',
                    );
                    return;
                  }

                  setState(() {
                    _isSubmitting = true;
                  });

                  final token = await storage.read(key: 'token');
                  if (token == null) {
                    _showErrorSnackBar(
                      context,
                      'Token missing. Please log in again.',
                    );
                    setState(() {
                      _isSubmitting = false;
                    });
                    return;
                  }

                  try {
                    await reportProvider.addReport({
                      'title': title,
                      'description': description,
                      'location': location,
                      'status': status,
                    }, token);

                    _formKey.currentState?.reset();
                    setState(() {
                      title = '';
                      description = '';
                      status = 'PENDING';
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Success!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Your report has been submitted successfully.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: accentGreen,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(12),
                      ),
                    );
                  } catch (e) {
                    _showErrorSnackBar(context, 'Error: ${e.toString()}');
                  } finally {
                    setState(() {
                      _isSubmitting = false;
                    });
                  }
                }
              },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[400] : accentGreen,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isDisabled
                  ? []
                  : [
                    BoxShadow(
                      color: accentGreen.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
        ),
        child: Center(
          child:
              _isSubmitting
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Submit Report',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}
