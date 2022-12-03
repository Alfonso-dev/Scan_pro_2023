import 'package:hive/hive.dart';
part 'scan_model.g.dart';

@HiveType(typeId: 0)
class ScanModel extends HiveObject {
  @HiveField(0)
  late String url;
  @HiveField(1)
  late DateTime date;
  @HiveField(2)
  late String img;
}
