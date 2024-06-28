import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateFootballFieldScreen extends StatefulWidget {
  final String fieldId;

  UpdateFootballFieldScreen({required this.fieldId});

  @override
  _UpdateFootballFieldScreenState createState() =>
      _UpdateFootballFieldScreenState();
}

class _UpdateFootballFieldScreenState
    extends State<UpdateFootballFieldScreen> {
  final _nameController = TextEditingController();
  final _hourlyRateController = TextEditingController();

  Future<void> _loadFieldData() async {
    DocumentSnapshot fieldDoc = await FirebaseFirestore.instance
        .collection('football_fields')
        .doc(widget.fieldId)
        .get();

    _nameController.text = fieldDoc['name'];
    _hourlyRateController.text = fieldDoc['hourlyRate'].toString();
  }

  Future<void> _updateFieldData() async {
    await FirebaseFirestore.instance
        .collection('football_fields')
        .doc(widget.fieldId)
        .update({
      'name': _nameController.text,
      'hourlyRate': double.parse(_hourlyRateController.text),
    });

    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _loadFieldData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Field Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Field Name'),
            ),
            TextField(
              controller: _hourlyRateController,
              decoration: InputDecoration(labelText: 'Hourly Rate'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateFieldData,
              child: Text('Update'),
            ),
          ],
        ),
      ),
    );
  }
}
