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
  String title = '', description = '', location = '', status = '';
  bool _isGettingLocation = true;

  final storage = FlutterSecureStorage();

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

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (val) => title = val,
              validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              onChanged: (val) => description = val,
              validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Status'),
              onChanged: (val) => status = val,
              validator: (val) => val == null || val.isEmpty ? 'Status is required' : null,
            ),
            const SizedBox(height: 16),
            if (_isGettingLocation)
              const CircularProgressIndicator()
            else
              TextFormField(
                initialValue: location,
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() && !_isGettingLocation) {
                  final token = await storage.read(key: 'token');
                  if (token == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Token missing. Please log in again.')),
                    );
                    return;
                  }

                  try {
                    await reportProvider.addReport({
                      'title': title,
                      'description': description,
                      'location': location,
                      'status': status,
                    }, token);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report added successfully')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}
