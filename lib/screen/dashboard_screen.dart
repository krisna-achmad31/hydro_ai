import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/pond_provider.dart';
import '../widgets/pond_card_widget.dart'; // MANGGIL WIDGET DISINI MAS!

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pondProvider = context.watch<PondProvider>();
    final data = pondProvider.data;

    return Scaffold(
      backgroundColor: const Color(0xFF1A237E), // Deep Blue Background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Smart Farm", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: const Icon(Icons.grid_view_rounded, color: Colors.white),
        actions: const [
          Icon(Icons.thermostat, color: Colors.white),
          SizedBox(width: 15)
        ],
      ),
      body: pondProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 1. TOP HEADER INFO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _topInfoItem("Active Ponds", "${data!.activePonds}"),
                _topInfoItem("Total Ponds", "${data.totalPonds}"),
              ],
            ),
          ),

          // 2. MAIN CONTENT AREA
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5), // Light Grey Background
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildWeatherSection(data),

                    // --- INI PEMANGGILAN WIDGETNYA MAS! ---
                    const PondCard(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget Cuaca Sesuai Referensi Gambar
  Widget _buildWeatherSection(data) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: const [
                  Icon(Icons.cloudy_snowing, size: 40, color: Colors.blue),
                  Text("Today", style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              _weatherItem("${data.weatherMin}°C", "min"),
              _weatherItem("${data.weatherMax}°C", "max"),
              _weatherItem("${data.weatherRain}%", "rain"),
              const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(),
          const SizedBox(height: 10),
          const Text(
              "13th waxing moon of the 8th lunar month",
              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)
          ),
        ],
      ),
    );
  }

  // Helper UI Atas
  Widget _topInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold
            )
        ),
      ],
    );
  }

  // Helper UI Cuaca
  Widget _weatherItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}