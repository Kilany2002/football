import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'play_station_room_management_screen.dart';

class PlayStationFormScreen extends StatefulWidget {
  @override
  _PlayStationFormScreenState createState() => _PlayStationFormScreenState();
}

class _PlayStationFormScreenState extends State<PlayStationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCountController = TextEditingController();
  final TextEditingController _vipRoomCountController = TextEditingController();
  final TextEditingController _privateRoomPriceController =
      TextEditingController();
  final TextEditingController _regularRoomPriceController =
      TextEditingController();
  bool hasCafe = false;
  bool hasWifi = false;
  bool showsMatches = false;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkIfFormSubmitted();
  }

  Future<void> _checkIfFormSubmitted() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .get();

      if (adminDoc.exists && adminDoc['playStationId'] != null) {
        // Redirect to management screen if form already submitted
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlayStationRoomManagementScreen(
                playStationId: adminDoc['playStationId']),
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Create PlayStation document
      DocumentReference playStationRef =
          await FirebaseFirestore.instance.collection('play_stations').add({
        'name': _nameController.text,
        'room_count': int.parse(_roomCountController.text),
        'vip_room_count': int.parse(_vipRoomCountController.text),
        'private_room_price': double.parse(_privateRoomPriceController.text),
        'regular_room_price': double.parse(_regularRoomPriceController.text),
        'has_cafe': hasCafe,
        'has_wifi': hasWifi,
        'shows_matches': showsMatches,
      });

      // Create rooms
      int roomCount = int.parse(_roomCountController.text);
      int vipRoomCount = int.parse(_vipRoomCountController.text);
      for (int i = 1; i <= roomCount; i++) {
        bool isVIP = i <= vipRoomCount;
        double hourlyRate = isVIP
            ? double.parse(_privateRoomPriceController.text)
            : double.parse(_regularRoomPriceController.text);
        await playStationRef.collection('rooms').add({
          'name': 'Room $i',
          'isBooked': false,
          'isVIP': isVIP,
          'hourlyRate': hourlyRate,
        });
      }

      // Associate PlayStation with admin
      await FirebaseFirestore.instance
          .collection('admins')
          .doc(user.uid)
          .set({'playStationId': playStationRef.id});

      // Clear the form fields
      _nameController.clear();
      _roomCountController.clear();
      _vipRoomCountController.clear();
      _privateRoomPriceController.clear();
      _regularRoomPriceController.clear();
      setState(() {
        hasCafe = false;
        hasWifi = false;
        showsMatches = false;
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PlayStation Hall Added Successfully')),
      );

      // Navigate to room management screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PlayStationRoomManagementScreen(playStationId: playStationRef.id),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add PlayStation Hall'),
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
                  decoration: InputDecoration(labelText: 'اسم المكان'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the place name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _roomCountController,
                  decoration: InputDecoration(labelText: 'عدد الغرف'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of rooms';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _vipRoomCountController,
                  decoration: InputDecoration(labelText: 'عدد الغرف الخاصه'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the number of VIP rooms';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _privateRoomPriceController,
                  decoration: InputDecoration(labelText: 'سعر الغرفه الخاصه'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the private room price';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _regularRoomPriceController,
                  decoration: InputDecoration(labelText: 'سعر الغرفه العاديه'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the regular room price';
                    }
                    return null;
                  },
                ),
                CheckboxListTile(
                  title: Text('كافيه'),
                  value: hasCafe,
                  onChanged: (value) {
                    setState(() {
                      hasCafe = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('واي فاي'),
                  value: hasWifi,
                  onChanged: (value) {
                    setState(() {
                      hasWifi = value!;
                    });
                  },
                ),
                CheckboxListTile(
                  title: Text('عرض ماتشات'),
                  value: showsMatches,
                  onChanged: (value) {
                    setState(() {
                      showsMatches = value!;
                    });
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
