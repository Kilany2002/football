import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'football_field_details_screen.dart';

class FootballFieldManagementScreen extends StatefulWidget {
  final String adminId;

  FootballFieldManagementScreen({required this.adminId});

  @override
  _FootballFieldManagementScreenState createState() =>
      _FootballFieldManagementScreenState();
}

class _FootballFieldManagementScreenState
    extends State<FootballFieldManagementScreen> {
  final _firestore = FirebaseFirestore.instance;

  Future<void> _toggleFieldStatus(String fieldId, bool isBooked) async {
    if (isBooked) {
      // Start booking and set start time
      await _firestore.collection('football_fields').doc(fieldId).update({
        'isBooked': true,
        'startTime': Timestamp.now(),
      });
    } else {
      // End booking and calculate total minutes
      DocumentSnapshot fieldDoc =
          await _firestore.collection('football_fields').doc(fieldId).get();

      Timestamp startTime = fieldDoc['startTime'];
      int totalMinutes =
          DateTime.now().difference(startTime.toDate()).inMinutes;

      await _firestore.collection('football_fields').doc(fieldId).update({
        'isBooked': false,
        'startTime': null,
        'totalMinutes': totalMinutes,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Football Fields'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder(
        stream: _firestore.collection('football_fields').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final fields = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];
              final fieldId = field.id;
              final fieldName = field['name'];
              final isBooked =
                  (field.data() as Map<String, dynamic>).containsKey('isBooked')
                      ? field['isBooked']
                      : false;

              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15.0),
                  title: Text(
                    fieldName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Switch(
                    value: isBooked,
                    onChanged: (value) {
                      _toggleFieldStatus(fieldId, value);
                    },
                    activeColor: Colors.red,
                    inactiveThumbColor: Colors.green,
                    inactiveTrackColor: Colors.greenAccent,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FootballFieldDetailsScreen(
                          fieldId: fieldId,
                          morningRate: field['morning_price'],
                          eveningRate: field['evening_price'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
