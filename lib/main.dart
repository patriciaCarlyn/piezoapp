import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:piezogenerator/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove the debug banner
      title: 'Shoes Piezo Generator', // Set the app title
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SensorDataDisplay(),
    );
  }
}

class SensorDataDisplay extends StatefulWidget {
  const SensorDataDisplay({super.key});

  @override
  _SensorDataDisplayState createState() => _SensorDataDisplayState();
}

class _SensorDataDisplayState extends State<SensorDataDisplay> {
  final DatabaseReference _sensorDataRef =
      FirebaseDatabase.instance.ref().child('sensor_data/current');
  final double _voltage = 5.0; // Example constant voltage in volts.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shoes Piezo Generator'),
        backgroundColor: Colors.blueAccent, // Modern color theme
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Padding around content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // StreamBuilder to display the real-time data from Firebase
              StreamBuilder<DatabaseEvent>(
                stream: _sensorDataRef.onValue,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red, fontSize: 18),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  // Check if snapshot data exists and is not null
                  if (snapshot.data?.snapshot.value == null) {
                    return const Text(
                      'No data available',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    );
                  }

                  // Safely parse the data
                  final currentValue = snapshot.data?.snapshot.value;
                  final double current =
                      double.tryParse(currentValue?.toString() ?? '0.0') ?? 0.0;

                  // Calculate power in watts
                  final double power = _voltage * current;

                  return Column(
                    children: [
                      Text(
                        'Current: ${current.toStringAsFixed(2)} A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10), // Spacing between rows
                      Text(
                        'Voltage: ${_voltage.toStringAsFixed(2)} V',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Power: ${power.toStringAsFixed(2)} W',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green, // Highlight the power output
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
