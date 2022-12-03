import 'package:hive/hive.dart';
import 'package:qr_scanner/model/scan_model.dart';

class Boxes {
  static Box<ScanModel> getScan() => Hive.box<ScanModel>("Scan");
}
