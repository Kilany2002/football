import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'field_detail_screen.dart';
import 'models/field.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('fields').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No fields available'));
          }

          var fields = snapshot.data!.docs.map((doc) => Field.fromFirestore(doc)).toList();

          return ListView.builder(
            itemCount: fields.length,
            itemBuilder: (context, index) {
              var field = fields[index];
              return ListTile(
                title: Text(field.name),
                subtitle: Text('Morning Price: ${field.morningPrice}'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FieldDetailScreen(fieldId: snapshot.data!.docs[index].id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
