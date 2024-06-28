import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class PlayStationRoomDetailsScreen extends StatefulWidget {
  final String playStationId;
  final String roomId;
  final double hourlyRate;

  PlayStationRoomDetailsScreen(
      {required this.playStationId,
      required this.roomId,
      required this.hourlyRate});

  @override
  _PlayStationRoomDetailsScreenState createState() =>
      _PlayStationRoomDetailsScreenState();
}

class _PlayStationRoomDetailsScreenState
    extends State<PlayStationRoomDetailsScreen> {
  Timer? _timer;
  DateTime? _startTime;
  int _totalMinutes = 0;
  double _totalCost = 0;
  List<Map<String, dynamic>> _cafeOrders = [];

  @override
  void initState() {
    super.initState();
    _loadRoomData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadRoomData() async {
    DocumentSnapshot roomDoc = await FirebaseFirestore.instance
        .collection('play_stations')
        .doc(widget.playStationId)
        .collection('rooms')
        .doc(widget.roomId)
        .get();

    if (roomDoc.exists && roomDoc['isBooked'] == true) {
      Timestamp startTime = roomDoc['startTime'];
      _startTime = startTime.toDate();
      _calculateTimeAndCost();
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _calculateTimeAndCost();
    });
  }

  void _calculateTimeAndCost() {
    setState(() {
      _totalMinutes = DateTime.now().difference(_startTime!).inMinutes;
      _totalCost = _calculateTotalCost();
    });
  }

  Future<void> _startBooking() async {
    setState(() {
      _startTime = DateTime.now();
      _totalMinutes = 0;
    });

    _startTimer();

    await FirebaseFirestore.instance
        .collection('play_stations')
        .doc(widget.playStationId)
        .collection('rooms')
        .doc(widget.roomId)
        .update({'isBooked': true, 'startTime': Timestamp.now()});
  }

  Future<void> _endBooking() async {
    _timer?.cancel();
    await FirebaseFirestore.instance
        .collection('play_stations')
        .doc(widget.playStationId)
        .collection('rooms')
        .doc(widget.roomId)
        .update({
      'isBooked': false,
      'startTime': null,
      'totalMinutes': _totalMinutes
    });
    setState(() {
      _startTime = null;
      _totalMinutes = 0;
      _totalCost = 0;
    });
  }

  Future<void> _toggleBooking(bool isBooked) async {
    if (isBooked) {
      await _startBooking();
    } else {
      await _endBooking();
    }
  }

  double _calculateTotalCost() {
    final hours = _totalMinutes / 60;
    double cafeCost = _cafeOrders.fold(
        0, (sum, item) => sum + item['price'] * item['quantity']);
    return hours * widget.hourlyRate + cafeCost;
  }

  void _addCafeOrder(Map<String, dynamic> item) {
    setState(() {
      _cafeOrders.add(item);
      _totalCost = _calculateTotalCost();
    });
  }

  Future<void> _showCafeOrderDialog() async {
    List<Map<String, dynamic>> items = [];
    final snapshot = await FirebaseFirestore.instance
        .collection('play_stations')
        .doc(widget.playStationId)
        .collection('cafe_items')
        .get();

    for (var doc in snapshot.docs) {
      items.add({
        'id': doc.id,
        'name': doc['name'],
        'price': doc['price'],
        'quantity': 1,
        'isSelected': false,
      });
    }

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text('إضافة منتجات من الكافيه'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: items.map((item) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['name']),
                    Checkbox(
                      value: item['isSelected'],
                      onChanged: (bool? value) {
                        setState(() {
                          item['isSelected'] = value!;
                        });
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (item['quantity'] > 1) {
                              setState(() {
                                item['quantity']--;
                              });
                            }
                          },
                        ),
                        Text(item['quantity'].toString()),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              item['quantity']++;
                            });
                          },
                        ),
                      ],
                    ),
                    Text('${item['price'] * item['quantity']} ج.م'),
                  ],
                );
              }).toList(),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  for (var item in items) {
                    if (item['isSelected']) {
                      _addCafeOrder(item);
                    }
                  }
                  Navigator.of(context).pop();
                },
                child: Text('إضافة إلى الطلب'),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الغرفة'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('play_stations')
            .doc(widget.playStationId)
            .collection('rooms')
            .doc(widget.roomId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var roomData = snapshot.data!;
          bool isBooked = roomData['isBooked'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اسم الغرفة: ${roomData['name']}',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('VIP: ${roomData['isVIP'] ? "نعم" : "لا"}',
                    style: TextStyle(fontSize: 16)),
                Text('الحالة: ${isBooked ? "محجوزة" : "متاحة"}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text('التكلفة الإجمالية: ${_totalCost.toStringAsFixed(2)} ج.م',
                    style: TextStyle(fontSize: 16)),
                Text('الوقت الإجمالي: $_totalMinutes دقيقة',
                    style: TextStyle(fontSize: 16)),
                SwitchListTile(
                  title: Text('الحجز', style: TextStyle(fontSize: 16)),
                  value: isBooked,
                  onChanged: (value) {
                    _toggleBooking(value);
                  },
                ),
                ElevatedButton(
                  onPressed: _showCafeOrderDialog,
                  child: Text('إضافة منتجات من الكافيه'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _cafeOrders.length,
                    itemBuilder: (context, index) {
                      final item = _cafeOrders[index];
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('${item['name']} x${item['quantity']}',
                              style: TextStyle(fontSize: 16)),
                          subtitle: Text(
                              'السعر الإجمالي: ${item['price'] * item['quantity']} ج.م',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
