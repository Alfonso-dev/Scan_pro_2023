import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner/pages/home/home.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../boxes.dart';
import '../../model/scan_model.dart';

class BarcodeScan extends StatefulWidget {
  const BarcodeScan({super.key});

  @override
  State<BarcodeScan> createState() => _BarcodeScanState();
}

class _BarcodeScanState extends State<BarcodeScan> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool flashOk = false;
  bool starCamera = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();

    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Future addBarcode(String url, DateTime time, String img) async {
    final scan = ScanModel()
      ..url = url
      ..date = time
      ..img = img;

    final box = Boxes.getScan();
    box.add(scan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Expanded(flex: 4, child: _buildQrView(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.all(10.w),
                child: IconButton(
                  onPressed: () async {
                    await controller?.toggleFlash();
                    if (flashOk == false) {
                      flashOk = true;
                    } else {
                      flashOk = false;
                    }
                    setState(() {});
                  },
                  icon: Image.asset(
                    flashOk == true
                        ? "lib/assets/flash.png"
                        : "lib/assets/flash_apagado.png",
                    color: Colors.white,
                    width: 10.w,
                    height: 10.h,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                child: IconButton(
                  onPressed: () async {
                    await controller?.flipCamera();
                    setState(() {});
                  },
                  icon: Image.asset(
                    "lib/assets/camera.png",
                    color: Colors.white,
                    width: 10.w,
                    height: 10.h,
                  ),
                ),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (result != null)
                Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Text(
                    'Resultado: ${result!.code}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                )
              else
                const Text(
                  'Scan a code',
                  style: TextStyle(color: Colors.red),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  starCamera == false
                      ? Container(
                          margin: const EdgeInsets.all(8),
                          child: ElevatedButton(
                            onPressed: () async {
                              await controller?.resumeCamera();
                              setState(() {
                                starCamera = true;
                              });
                            },
                            child: const Text('Iniciar camara',
                                style: TextStyle(fontSize: 20)),
                          ),
                        )
                      : Container()
                ],
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      formatsAllowed: const [
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.code128,
        BarcodeFormat.code39,
        BarcodeFormat.code93,
        BarcodeFormat.codabar,
      ],
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 40,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    int count = 0;
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      count++;
      setState(() {
        result = scanData;
      });

      if (count == 1) {
        addBarcode(
          result!.code.toString(),
          DateTime.now(),
          "lib/assets/barcode.png",
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const Home(),
          ),
        );
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
