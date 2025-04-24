  import 'package:flutter/material.dart';
  import 'package:frontend/providers/report_provider.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:provider/provider.dart';
  import 'package:geocoding/geocoding.dart';
  import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
          final Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);

          if (placemarks.isNotEmpty) {
            final Placemark place = placemarks.first;
            final address = '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
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
      final theme = Theme.of(context);
      final textColor = theme.colorScheme.onSurface;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add New Report',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Title',
                  onChanged: (val) => title = val,
                  validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                  textColor: textColor,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Description',
                  onChanged: (val) => description = val,
                  validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
                  textColor: textColor,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: status,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: textColor),
                          onChanged: (String? newValue) {
                            setState(() {
                              status = newValue!;
                            });
                          },
                          items: statusOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: TextStyle(color: textColor),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _isGettingLocation
                          ? Center(
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Getting location...',
                                    style: TextStyle(color: textColor),
                                  ),
                                ],
                              ),
                            )
                          : Text(
                              location,
                              style: TextStyle(color: textColor),
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: _isSubmitting || _isGettingLocation
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isSubmitting = true;
                            });

                            final token = await storage.read(key: 'token');
                            if (token == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Token missing. Please log in again.',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
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

                              // Reset form
                              _formKey.currentState?.reset();
                              setState(() {
                                title = '';
                                description = '';
                                status = 'PENDING';
                              });

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 10),
                                      Text(
                                        'Report added successfully!',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Error: ${e.toString()}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
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
                      color: _isSubmitting || _isGettingLocation ? Colors.grey : textColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Submit Report',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget _buildTextField({
      required String label,
      required Function(String) onChanged,
      required String? Function(String?) validator,
      required Color textColor,
      int maxLines = 1,
    }) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
              ),
            ),
            TextFormField(
              style: TextStyle(color: textColor),
              onChanged: onChanged,
              validator: validator,
              maxLines: maxLines,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      );
    }
  }