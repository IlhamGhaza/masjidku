import 'package:flutter/material.dart';

class UpcomingEventPage extends StatefulWidget {
  const UpcomingEventPage({super.key});

  @override
  State<UpcomingEventPage> createState() => _UpcomingEventPageState();
}

class _UpcomingEventPageState extends State<UpcomingEventPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events'),),
      body: const Center(child: Text('Upcoming Events')),
    );
  }
}