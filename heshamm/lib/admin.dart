import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              child: ListTile(
                title: Text('Football Fields'),
                onTap: () {
                  Navigator.pushNamed(context, '/footballFields');
                },
              ),
            ),
            SizedBox(height: 20),
            Card(
              child: ListTile(
                title: Text('PlayStation'),
                onTap: () {
                  Navigator.pushNamed(context, '/playStation');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
