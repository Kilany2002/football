import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateAdminScreen extends StatefulWidget {
  final String playStationId;

  UpdateAdminScreen({required this.playStationId});

  @override
  _UpdateAdminScreenState createState() => _UpdateAdminScreenState();
}

class _UpdateAdminScreenState extends State<UpdateAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomCountController = TextEditingController();
  final TextEditingController _vipRoomCountController = TextEditingController();
  final TextEditingController _privateRoomPriceController = TextEditingController();
  final TextEditingController _regularRoomPriceController = TextEditingController();
  bool hasCafe = false;
  bool hasWifi = false;
  bool showsMatches = false;

  @override
  void initState() {
    super.initState();
    _loadPlayStationDetails();
  }

  Future<void> _loadPlayStationDetails() async {
    DocumentSnapshot playStationDoc = await FirebaseFirestore.instance
        .collection('play_stations')
        .doc(widget.playStationId)
        .get();

    if (playStationDoc.exists) {
      setState(() {
        _nameController.text = playStationDoc['name'];
        _roomCountController.text = playStationDoc['room_count'].toString();
        _vipRoomCountController.text = playStationDoc['vip_room_count'].toString();
        _privateRoomPriceController.text = playStationDoc['private_room_price'].toString();
        _regularRoomPriceController.text = playStationDoc['regular_room_price'].toString();
        hasCafe = playStationDoc['has_cafe'];
        hasWifi = playStationDoc['has_wifi'];
        showsMatches = playStationDoc['shows_matches'];
      });
    }
  }

  Future<void> _updatePlayStationDetails() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('play_stations')
          .doc(widget.playStationId)
          .update({
        'name': _nameController.text,
        'room_count': int.parse(_roomCountController.text),
        'vip_room_count': int.parse(_vipRoomCountController.text),
        'private_room_price': double.parse(_privateRoomPriceController.text),
        'regular_room_price': double.parse(_regularRoomPriceController.text),
        'has_cafe': hasCafe,
        'has_wifi': hasWifi,
        'shows_matches': showsMatches,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PlayStation Details Updated Successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Admin Data'),
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
                  onPressed: _updatePlayStationDetails,
                  child: Text('Update'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
