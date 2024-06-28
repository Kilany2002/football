import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class FootballFieldDetailsScreen extends StatefulWidget {
  final String fieldId;
  final double morningRate;
  final double eveningRate;

  FootballFieldDetailsScreen({
    required this.fieldId,
    required this.morningRate,
    required this.eveningRate,
  });

  @override
  _FootballFieldDetailsScreenState createState() =>
      _FootballFieldDetailsScreenState();
}

class _FootballFieldDetailsScreenState
    extends State<FootballFieldDetailsScreen> {
  Timer? _timer;
  DateTime? _startTime;
  int _totalMinutes = 0;
  double _totalCost = 0;

  @override
  void initState() {
    super.initState();
    _loadFieldData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadFieldData() async {
    DocumentSnapshot fieldDoc = await FirebaseFirestore.instance
        .collection('football_fields')
        .doc(widget.fieldId)
        .get();

    if (fieldDoc.exists && fieldDoc['isBooked'] == true) {
      Timestamp startTime = fieldDoc['startTime'];
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
        .collection('football_fields')
        .doc(widget.fieldId)
        .update({'isBooked': true, 'startTime': Timestamp.now()});
  }

  Future<void> _endBooking() async {
    _timer?.cancel();
    await FirebaseFirestore.instance
        .collection('football_fields')
        .doc(widget.fieldId)
        .update({
      'isBooked': false,
      'startTime': null,
      'totalMinutes': _totalMinutes,
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
    final now = DateTime.now();
    final rate = now.hour >= 6 && now.hour < 18
        ? widget.morningRate
        : widget.eveningRate;
    return hours * rate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Field Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('football_fields')
            .doc(widget.fieldId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var fieldData = snapshot.data!;
          bool isBooked = fieldData['isBooked'] ?? false;

          return Column(
            children: [
              Text('Field Name: ${fieldData['name']}'),
              Text('Status: ${isBooked ? "Booked" : "Available"}'),
              Text('Total Cost: ${_totalCost.toStringAsFixed(2)} ج.م'),
              Text('Total Time: $_totalMinutes minutes'),
              Switch(
                value: isBooked,
                onChanged: (value) {
                  _toggleBooking(value);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
