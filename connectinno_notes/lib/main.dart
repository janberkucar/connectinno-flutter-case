import 'package:connectinno_notes/app/app.dart';
import 'package:connectinno_notes/bootstrap.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  final bootstrap = await AppBootstrap.create();
  runApp(ConnectinnoApp(bootstrap: bootstrap));
}
