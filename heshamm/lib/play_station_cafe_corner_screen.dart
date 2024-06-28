import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayStationCafeCornerScreen extends StatelessWidget {
  final String playStationId;

  PlayStationCafeCornerScreen({required this.playStationId});

  Future<void> _addCafeItem(BuildContext context) async {
    final _nameController = TextEditingController();
    final _priceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('إضافة منتج'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'الاسم'),
              ),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'السعر'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text;
                final price = double.parse(_priceController.text);
                await FirebaseFirestore.instance
                    .collection('play_stations')
                    .doc(playStationId)
                    .collection('cafe_items')
                    .add({'name': name, 'price': price});
                Navigator.of(context).pop();
              },
              child: Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اضافة منتج'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _addCafeItem(context),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('play_stations')
            .doc(playStationId)
            .collection('cafe_items')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(10.0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Card(
                elevation: 5,
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: ListTile(
                  contentPadding: EdgeInsets.all(15.0),
                  title: Text(
                    item['name'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '${item['price']} ج.م',
                    style: TextStyle(color: Colors.green, fontSize: 16),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
