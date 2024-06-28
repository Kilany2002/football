import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/field.dart';

class FieldDetailScreen extends StatelessWidget {
  final String fieldId;

  FieldDetailScreen({required this.fieldId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Field Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('fields').doc(fieldId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }
          Field field = Field.fromFirestore(snapshot.data!);
          return Column(
            children: [
              Image.network(field.imageUrl),
              Text('Morning Price: ${field.morningPrice}'),
              Text('Evening Price: ${field.eveningPrice}'),
              Text('Slots:'),
              Expanded(
                child: ListView.builder(
                  itemCount: field.slots.length,
                  itemBuilder: (context, index) {
                    String timeRange = field.slots.keys.elementAt(index);
                    String status = field.slots[timeRange] == 'available' ? 'Available' : 'Booked';

                    return ListTile(
                      title: Text(timeRange),
                      trailing: Text(status),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Implement booking logic here
                },
                child: Text('Book Now'),
              ),
            ],
          );
        },
      ),
    );
  }
}
