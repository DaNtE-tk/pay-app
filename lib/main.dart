import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gptapp/models/paymentData.dart';
// import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PayGate App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PayGate'),
      ),
      body: const Center(
        child: Text(
          'Welcome to ₹PayGate',
          style: TextStyle(fontSize: 24),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRCodeScannerPage()),
          );
        },
        tooltip: 'Scan QR Code',
        child: const Icon(Icons.qr_code),
      ),
    );
  }
}

class QRCodeScannerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  late QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderWidth: 10,
          borderLength: 20,
          borderRadius: 20,
          borderColor: Colors.green,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      controller.pauseCamera();
      // Simulating a GET request
      if (scanData.code != null && scanData.code!.length > 5) {
        if (scanData.code?.substring(0, 6) == 'hqr:-') {
          String qrCodeData = scanData.code!.substring(5);
          // Check if the code is not null before parsing as URI
          var response = await http.get(Uri.parse(qrCodeData));

          if (response.statusCode == 200) {
            String responseData = json.decode(response.body);

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => DataDisplayPage(data: responseData),
            //   ),
            // );
          } else {
            // Handle error
            print('Failed to fetch data');
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Invalid QR Code'),
                content: Text('The QR Code is not in the expected format.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the AlertDialog
                      Navigator.pushReplacement(
                        // Navigate back to the home page
                        context,
                        MaterialPageRoute(builder: (context) => HomePage()),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {
        // Handle case where scanData.code is null
        print('QR Code is null');
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class DataDisplayPage extends StatelessWidget {
  final String data;

  DataDisplayPage({required this.data});

  @override
  Widget build(BuildContext context) {
    // Parse JSON data into PaymentOverlay object
    PaymentOverlay paymentOverlay = PaymentOverlay.fromJson(json.decode(data));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Display'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Beneficiary: ${paymentOverlay.beneficiary}'),
              Text(
                  'Amount: ${paymentOverlay.amount} ${paymentOverlay.currency}'),
              Text('Bank Code: ${paymentOverlay.bankCode}'),
              // Add other fields as needed
            ],
          ),
        ),
      ),
    );
  }
}
