
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
  String _predictionStatus = 'N/A';
  String _recommendation = 'Fill the form to get a prediction.';
  String _eggProduction = '--';
  Color _cardColor = Colors.white;
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
          _temperature = 22.0 + Random().nextDouble() * 8; // Simulate 22°C to 30°C
          _humidity = 55.0 + Random().nextDouble() * 15; // Simulate 55% to 70%
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

  Future<void> _getPrediction() async {
    if (_chickenController.text.isEmpty) {
      if (!mounted) return; // FIX: Check if mounted before using BuildContext
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the amount of chicken.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulate a short delay
    await Future.delayed(const Duration(milliseconds: 1000));

    try {
      // Parse all inputs with defaults
      final int chickenCount = int.tryParse(_chickenController.text) ?? 0;
      final double ammonia = double.tryParse(_ammoniaController.text) ?? 0;
      final double light = double.tryParse(_lightController.text) ?? 15;
      final double noise = double.tryParse(_noiseController.text) ?? 70;

      // --- Advanced Health & Recommendation Logic ---
      String newStatus = 'Healthy 🐔';
      String newRecommendation = 'Conditions are optimal. Keep up the good work!';
      Color newCardColor = Colors.green.shade100;

      // Check for issues, ordered by priority
      if (ammonia > 25) {
        newStatus = 'Danger ☣️';
        newRecommendation = 'Ammonia level is critical! Check ventilation and litter immediately.';
        newCardColor = Colors.red.shade100;
      } else if (_temperature > 28) {
        newStatus = 'Warning 🔥';
        newRecommendation = 'Suhu terlalu tinggi! Kurangi pakan 10% dan perbaiki ventilasi.';
        newCardColor = Colors.amber.shade100;
      } else if (_temperature < 22) {
        newStatus = 'Warning ❄️';
        newRecommendation = 'Suhu terlalu rendah. Tambah pakan 5% dan periksa pemanas.';
        newCardColor = Colors.amber.shade100;
      } else if (_humidity > 70) {
        newStatus = 'Warning 💧';
        newRecommendation = 'Humidity is high. Increase ventilation to reduce moisture.';
        newCardColor = Colors.amber.shade100;
      } else if (noise > 85) {
        newStatus = 'Warning 🔊';
        newRecommendation = 'Noise level is high. Minimize disturbances near the coop.';
        newCardColor = Colors.amber.shade100;
      } else if (light < 10) { // FIX: Using the 'light' variable
        newStatus = 'Warning 💡';
        newRecommendation = 'Light intensity is too low. Ensure at least 14-16 hours of light.';
        newCardColor = Colors.amber.shade100;
      }

      // --- Egg Production Formula ---
      double baseProduction = chickenCount * 0.85;
      double tempFactor = (_temperature < 22 || _temperature > 28) ? 0.95 : 1.0;
      double humidityFactor = (_humidity < 50 || _humidity > 70) ? 0.97 : 1.0;
      int finalPrediction = (baseProduction * tempFactor * humidityFactor).round();

      if (mounted) {
        setState(() {
          _predictionStatus = newStatus;
          _recommendation = newRecommendation;
          _cardColor = newCardColor;
          _eggProduction = finalPrediction.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _predictionStatus = 'Error';
          _recommendation = 'Could not process the prediction. Please check your inputs.';
          _cardColor = Colors.grey.shade300;
          _eggProduction = '--';
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
            _buildPredictionButton(),
            const SizedBox(height: 25),
            _buildPredictionResultCard(),
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

  Widget _buildPredictionButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: _isLoading ? Container() : const Icon(Icons.analytics_outlined),
        label: Text(_isLoading ? 'Calculating...' : 'Calculate Prediction', style: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: _isLoading ? null : _getPrediction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1B3D6D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildPredictionResultCard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, spreadRadius: 1, blurRadius: 5)], // FIX: Replaced withOpacity
        border: Border.all(color: Colors.black12) // FIX: Replaced withOpacity
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AI Prediction', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const Divider(height: 20),

          // Status
          Text('Status: $_predictionStatus', style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 15),

          // Recommendation
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.orange, size: 24),
              const SizedBox(width: 8),
              Expanded(child: Text('Recommendation: $_recommendation', style: GoogleFonts.lato(fontSize: 16))),
            ],
          ),
          const SizedBox(height: 15),

          // Egg Production
          Row(
             crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                const Icon(Icons.egg_outlined, color: Colors.brown, size: 24),
                const SizedBox(width: 8),
                Expanded(child: Text('Predicted Daily Egg Production: $_eggProduction', style: GoogleFonts.lato(fontSize: 16))),
            ],
          )

        ],
      ),
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
          labelStyle: GoogleFonts.lato(),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
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
