import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_scanner/model/scan_model.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../boxes.dart';

class QRscan extends StatefulWidget {
  const QRscan({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRscanState();
}

class _QRscanState extends State<QRscan> {
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

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(flex: 4, child: _buildQrView(context)),
            ],
          ),
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
                  controller?.getCameraInfo() == true
                      ? Container()
                      : starCamera == false
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

  Future addScan(String url, DateTime time, String img) async {
    final scan = ScanModel()
      ..url = url
      ..date = time
      ..img = img;

    final box = Boxes.getScan();
    box.add(scan);
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
      formatsAllowed: const [BarcodeFormat.qrcode],
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
      addScan(
          result!.code.toString(), DateTime.now(), "lib/assets/codigo_qr.png");
      _launchUrl(result?.code);
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
