import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'play_station_room_details_screen.dart';
import 'play_station_cafe_corner_screen.dart';
import 'admin_profile_screen.dart';

class PlayStationRoomManagementScreen extends StatefulWidget {
  final String playStationId;

  PlayStationRoomManagementScreen({required this.playStationId});

  @override
  _PlayStationRoomManagementScreenState createState() =>
      _PlayStationRoomManagementScreenState();
}

class _PlayStationRoomManagementScreenState
    extends State<PlayStationRoomManagementScreen> {
  final _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _toggleRoomStatus(String roomId, bool isBooked) async {
    if (isBooked) {
      // Start booking and set start time
      await _firestore
          .collection('play_stations')
          .doc(widget.playStationId)
          .collection('rooms')
          .doc(roomId)
          .update({
        'isBooked': true,
        'startTime': Timestamp.now(),
      });
    } else {
      // End booking and calculate total minutes
      DocumentSnapshot roomDoc = await _firestore
          .collection('play_stations')
          .doc(widget.playStationId)
          .collection('rooms')
          .doc(roomId)
          .get();

      Timestamp startTime = roomDoc['startTime'];
      int totalMinutes =
          DateTime.now().difference(startTime.toDate()).inMinutes;

      await _firestore
          .collection('play_stations')
          .doc(widget.playStationId)
          .collection('rooms')
          .doc(roomId)
          .update({
        'isBooked': false,
        'startTime': null,
        'totalMinutes': totalMinutes,
      });
    }
  }

  Future<void> _addRoom() async {
    await _firestore
        .collection('play_stations')
        .doc(widget.playStationId)
        .collection('rooms')
        .add({'name': 'New Room', 'isBooked': false, 'isVIP': false});
  }

  @override
  Widget build(BuildContext context) {
    Widget currentScreen;
    String appBarTitle = '';

    switch (_selectedIndex) {
      case 0:
        appBarTitle = 'الغرف';
        currentScreen = StreamBuilder(
          stream: _firestore
              .collection('play_stations')
              .doc(widget.playStationId)
              .collection('rooms')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final rooms = snapshot.data!.docs;

            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final roomId = room.id;
                final roomName = room['name'];
                final isBooked = room['isBooked'];
                final isVIP = room['isVIP'];
                final hourlyRate = room['hourlyRate'];

                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15.0),
                    title: Text(
                      roomName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    leading: isVIP
                        ? Icon(Icons.star, color: Colors.yellow)
                        : Icon(Icons.room, color: Colors.blueAccent),
                    trailing: Switch(
                      value: isBooked,
                      onChanged: (value) {
                        _toggleRoomStatus(roomId, value);
                      },
                      activeColor: Colors.red,
                      inactiveThumbColor: Colors.green,
                      inactiveTrackColor: Colors.greenAccent,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayStationRoomDetailsScreen(
                            playStationId: widget.playStationId,
                            roomId: roomId,
                            hourlyRate: hourlyRate,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        );
        break;
      case 1:
        appBarTitle = 'التسالي';
        currentScreen =
            PlayStationCafeCornerScreen(playStationId: widget.playStationId);
        break;
      case 2:
        appBarTitle = 'الملف الشخصي';
        currentScreen = AdminProfileScreen(
          playStationId: widget.playStationId,
          adminId: '',
        );
        break;
      default:
        appBarTitle = 'Unknown';
        currentScreen = Center(child: Text('Unknown tab'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        automaticallyImplyLeading: false,
      ),
      body: currentScreen,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.room),
            label: 'الغرف',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_cafe),
            label: 'التسالي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
