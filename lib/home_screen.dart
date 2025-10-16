
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers for manual input
  final _chickenController = TextEditingController();
  final _feedingController = TextEditingController();
  final _ammoniaController = TextEditingController();
  final _lightController = TextEditingController();
  final _noiseController = TextEditingController();

  // State for sensor data
  double _temperature = 25.0;
  double _humidity = 60.0;

  // State for prediction
  String _predictionResult = '--';
  bool _isLoading = false;

  // Timer for simulating sensor updates
  Timer? _sensorTimer;

  @override
  void initState() {
    super.initState();
    // Simulate real-time sensor data updates every 3 seconds
    _sensorTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _temperature = 24.0 + Random().nextDouble() * 2; // 24.0 to 26.0
          _humidity = 58.0 + Random().nextDouble() * 4; // 58.0 to 62.0
        });
      }
    });
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    _chickenController.dispose();
    _feedingController.dispose();
    _ammoniaController.dispose();
    _lightController.dispose();
    _noiseController.dispose();
    super.dispose();
  }

  // Re-enabled prediction logic with a simple formula
  Future<void> _getPrediction() async {
    if (_chickenController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the amount of chicken.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _predictionResult = 'Calculating...';
    });

    // Simulate a short delay for calculation feel
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final int chickenCount = int.tryParse(_chickenController.text) ?? 0;
      
      // Simple Formula Logic
      // 1. Base production: Assume 1     chicken produces ~0.85 eggs/day on average.
      double baseProduction = chickenCount * 0.85;

      // 2. Adjustment factors based on environment.
      double tempFactor = 1.0;
      if (_temperature < 20 || _temperature > 26) {
        tempFactor = 0.95; // 5% reduction for non-ideal temperature
      }

      double humidityFactor = 1.0;
      if (_humidity < 50 || _humidity > 70) {
        humidityFactor = 0.97; // 3% reduction for non-ideal humidity
      }

      // 3. Final calculation
      int finalPrediction = (baseProduction * tempFactor * humidityFactor).round();

      if (mounted) {
        setState(() {
          _predictionResult = finalPrediction.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _predictionResult = 'Error';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Prediction Dashboard',
          style: GoogleFonts.montserrat(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black54),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              context.go('/');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(user),
            const SizedBox(height: 25),
            _buildSensorSection(),
            const SizedBox(height: 25),
            _buildManualInputSection(),
            const SizedBox(height: 30),
            _buildPredictionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(User? user) {
    return Text(
      'Welcome, ${user?.email ?? 'Guest'}.',
      style: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSensorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Real-time Sensor Data', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Row(
          children: [
            _buildSensorCard('Temperature', '${_temperature.toStringAsFixed(1)} °C', Icons.thermostat_outlined, Colors.orangeAccent),
            const SizedBox(width: 15),
            _buildSensorCard('Humidity', '${_humidity.toStringAsFixed(1)} %', Icons.water_drop_outlined, Colors.blueAccent),
          ],
        ),
      ],
    );
  }

  Widget _buildManualInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Manual Input Parameters', style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        Wrap(
          spacing: 15,
          runSpacing: 15,
          children: [
            _buildInputField(_chickenController, 'Amount of Chicken'),
            _buildInputField(_feedingController, 'Amount of Feeding (kg)'),
            _buildInputField(_ammoniaController, 'Ammonia (ppm)'),
            _buildInputField(_lightController, 'Light Intensity (lux)'),
            _buildInputField(_noiseController, 'Noise (dB)'),
          ],
        )
      ],
    );
  }

  Widget _buildPredictionSection() {
    return Column(
      children: [
        Center(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.analytics_outlined),
            label: Text('Calculate Prediction', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: _isLoading ? null : _getPrediction, // Re-enabled the button
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3D6D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 25),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
          ),
          child: Column(
            children: [
              Text('Predicted Daily Egg Production', style: GoogleFonts.montserrat(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 10),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      _predictionResult,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.robotoMono(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFFD700), 
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField(TextEditingController controller, String label) {
    return SizedBox(
      width: 160,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildSensorCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
                Icon(icon, color: color, size: 30),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.robotoMono(fontSize: 22, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
