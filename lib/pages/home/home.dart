import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qr_scanner/boxes.dart';
import 'package:qr_scanner/model/scan_model.dart';
import 'package:qr_scanner/pages/scan_bar_code/scanner_bar_code.dart';
import 'package:qr_scanner/pages/scan_qr/scanner_qr.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Scan pro 2023')),
      ),
      body: ValueListenableBuilder<Box<ScanModel>>(
        valueListenable: Boxes.getScan().listenable(),
        builder: (context, box, child) {
          final scan = box.values.toList().cast<ScanModel>();
          return buildContent(scan);
        },
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_home,
        backgroundColor: Colors.blue,
        children: [
          SpeedDialChild(
            child: Container(
              width: 6.w,
              height: 6.h,
              child: Image.asset("lib/assets/barcode.png"),
            ),
            label: 'Barcode Scan',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const BarcodeScan(),
            )),
          ),
          SpeedDialChild(
            child: Container(
              width: 6.w,
              height: 6.h,
              child: Image.asset("lib/assets/codigo_qr.png"),
            ),
            label: 'QR Scan',
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const QRscan(),
            )),
          ),
        ],
      ),
    );
  }

  Widget buildContent(List<ScanModel> scan) {
    if (scan.isEmpty) {
      return Center(
        child: Text(
          'Historial vacio',
          style: TextStyle(fontSize: 24.sp),
        ),
      );
    } else {
      return Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: scan.length,
              itemBuilder: (context, index) {
                final scan_2 = scan[index];
                return buildScan(context, scan_2);
              },
            ),
          ),
        ],
      );
    }
  }

  Widget buildScan(BuildContext context, ScanModel scan) {
    return Card(
      color: Colors.white,
      child: InkWell(
        onTap: () => _launchUrl(scan.url),
        child: ListTile(
          leading: Image.asset(
            scan.img,
            width: 10.w,
          ),
          title: Text(scan.url),
          subtitle: Text(scan.date.toString()),
          trailing: IconButton(
            onPressed: () => deleteScan(scan),
            icon: Icon(
              Icons.delete_rounded,
              color: Colors.red,
              size: 5.h,
            ),
          ),
        ),
      ),
    );
  }

  void deleteScan(ScanModel scan) {
    scan.delete();
  }
}
