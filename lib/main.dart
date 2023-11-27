import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gptapp/models/paymentData.dart';
import 'package:easy_upi_payment/easy_upi_payment.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'app_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // for initializing local storage
  final appStorage = AppStorage();
  await appStorage.initAppStorage();

  runApp(
    ProviderScope(
      overrides: [
        appStorageProvider.overrideWithValue(appStorage),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  // const MyApp({super.key})

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        if (scanData.code?.substring(0, 5) == 'hqr:-') {
          String qrCodeData = scanData.code!.substring(5);
          // Check if the code is not null before parsing as URI
          var response = await http.get(Uri.parse(qrCodeData));

          if (response.statusCode == 200) {
            // String responseData = json.decode(response.body);
            // print(response);
            PaymentOverlay paymentOverlay =
                PaymentOverlay.fromJson(json.decode(response.body));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DataDisplayPage(paymentOverlay: paymentOverlay),
              ),
              //  MaterialPageRoute(builder: (context) => DataDisplayPage(paymentOverlay:PaymentOverlay.fromJson(response.body))),
            );
          } else {
            // Handle error
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Could not fetch data'),
                  content: const Text(
                      'Failed to establish communication with the server.'),
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
                      child: const Text('OK'),
                    ),
                  ],
                );
              },
            );
            // print('Failed to fetch data');
          }
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Invalid QR Code'),
                content:
                    const Text('The QR Code is not in the expected format.'),
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
                    child: const Text('OK'),
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

class DataDisplayPage extends StatefulWidget {
  // const DataDisplayPage({super.key})

  final PaymentOverlay paymentOverlay;
  DataDisplayPage({required this.paymentOverlay});

  @override
  State<DataDisplayPage> createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
// class _DataDisplayPageState extends HookConsumerWidget {
  @override
  Widget build(BuildContext context) {
    // final formKeyRef = useRef(GlobalKey(<FormState>()));
    // Parse JSON data into PaymentOverlay object
    // PaymentOverlay paymentOverlay = PaymentOverlay.fromJson(json.decode(data));

    // REFERENCE LOGIC
    // final

    // RETURN LOGIC
    return Scaffold(
        appBar: AppBar(
          title: const Text('Transaction Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 5.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Beneficiary'),
                    subtitle: Text(widget.paymentOverlay.beneficiary),
                    leading: const Icon(Icons.person),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('UPI ID'),
                    subtitle: Text(widget.paymentOverlay.upiId),
                    leading: const Icon(Icons.wallet),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Amount'),
                    subtitle: Text('₹${widget.paymentOverlay.amount}'),
                    leading: const Icon(Icons.money_outlined),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Transaction Ref.'),
                    subtitle: Text(widget.paymentOverlay.referenceId),
                    leading: const Icon(Icons.tag),
                  ),
                  const Divider(),
                  Container(
                    margin: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        _makePayment(context);
                        // Navigator.push(
                        //     context, MaterialPageRoute(builder: (context) => const MainView()));
                      },
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(
                            const Size.fromHeight(52)),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                50), // Adjust the radius as needed
                          ),
                        ),
                      ),
                      child: const Text(
                        'Make Payment',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                  // Text('Upi ID: ${widget.paymentOverlay.upiId}'),
                  // Text('Amount: ${widget.paymentOverlay.amount} ${widget.paymentOverlay.currency}'),
                  // Text('Bank Code: ${widget.paymentOverlay.bankCode}'),
                  // Add other fields as needed
                ],
              ),
            ),
          ),
        ));
  }

  void _makePayment(BuildContext context) async {
    // String vpa = widget.paymentOverlay.upiId;

    final res = await EasyUpiPaymentPlatform.instance.startPayment(
      EasyUpiPaymentModel(
        payeeVpa: widget.paymentOverlay.upiId,
        payeeName: widget.paymentOverlay.beneficiary,
        amount: double.parse(widget.paymentOverlay.amount),
        description:
            'Harting-Pay payment for Ref id: ${(widget.paymentOverlay.referenceId)}',
        transactionRefId: widget.paymentOverlay.referenceId,
      ),
    );
    developer.log("$res", name: 'app.payment');
    if (res != null) {
      developer.log('Transaction success ${res}');
    } else {
      developer.log('Transaction failed');
    }
    // developer.log(res);
    // String newReferenceID = _generateReferenceId();
  }
}
