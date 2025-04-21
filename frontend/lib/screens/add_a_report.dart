import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/report_provider.dart';
import 'package:provider/provider.dart';

class AddReportScreen extends StatefulWidget {
  const AddReportScreen({super.key});

  @override
  State<AddReportScreen> createState() => _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '', description = '', location = '', status = '';

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: Text("Add Report")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(decoration: InputDecoration(labelText: 'Title'), onChanged: (val) => title = val),
              TextFormField(decoration: InputDecoration(labelText: 'Description'), onChanged: (val) => description = val),
              TextFormField(decoration: InputDecoration(labelText: 'Location'), onChanged: (val) => location = val),
              TextFormField(decoration: InputDecoration(labelText: 'Status'), onChanged: (val) => status = val),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await reportProvider.addReport({
                      'title': title,
                      'description': description,
                      'location': location,
                      'status': status,
                      'user_id': auth.user?.user_id, 
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Report added successfully')));
                  }
                },
                child: Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
