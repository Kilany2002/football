import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'football_field_management_screen.dart';

class FootballFieldFormScreen extends StatefulWidget {
  final String adminId;
  final String role;

  FootballFieldFormScreen({required this.adminId, required this.role});

  @override
  _FootballFieldFormScreenState createState() => _FootballFieldFormScreenState();
}

class _FootballFieldFormScreenState extends State<FootballFieldFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _morningPriceController = TextEditingController();
  final TextEditingController _eveningPriceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentReference fieldRef = await FirebaseFirestore.instance.collection('football_fields').add({
          'name': _nameController.text,
          'morning_price': double.parse(_morningPriceController.text),
          'evening_price': double.parse(_eveningPriceController.text),
          'location': _locationController.text,
          'user_id': user.uid,
          'isBooked': false, // Initialize isBooked field
          'startTime': null,
          'totalMinutes': 0,
        });

        // Associate the football field with the admin
        await FirebaseFirestore.instance.collection('admins').doc(user.uid).set({
          'football_field_id': fieldRef.id,
          'role': widget.role,
        });

        // Clear the form fields
        _nameController.clear();
        _morningPriceController.clear();
        _eveningPriceController.clear();
        _locationController.clear();

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Football Field Added Successfully')),
        );

        // Navigate to the management screen
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FootballFieldManagementScreen(adminId: widget.adminId),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You need to be signed in to add a football field')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Football Field'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المعلب',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the field name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _morningPriceController,
                  decoration: InputDecoration(
                    labelText: 'سعر الساعة صباحا',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the morning price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _eveningPriceController,
                  decoration: InputDecoration(
                    labelText: 'سعر الساعة ليلا',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the evening price';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'المكان',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the location';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
