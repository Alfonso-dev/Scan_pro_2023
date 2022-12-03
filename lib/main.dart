import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_scanner/model/scan_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'pages/home/home.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScanModelAdapter());
  await Hive.openBox<ScanModel>("Scan");
  runApp(
    ResponsiveSizer(
      builder: (p0, p1, p2) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Home(),
        );
      },
    ),
  );
}
