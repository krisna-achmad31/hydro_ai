import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/pond_provider.dart';

class PondCard extends StatelessWidget {
  const PondCard({super.key});

  @override
  Widget build(BuildContext context) {
    final pondProvider = context.watch<PondProvider>();
    final data = pondProvider.data;

    if (data == null) return const SizedBox();

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Smart Pond 1", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                    Text("Update: ${data.lastUpdate.split('T')[0]}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.pets, size: 12, color: Colors.orange[900]),
                      const SizedBox(width: 4),
                      Text(
                        data.animalType.toUpperCase(), // Menampilkan "SHRIMP"
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[900]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- GRID DATA SENSOR + LIMITS ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sensorItem("DO", data.oxygen.toString(), "mg/L", "Min: ${data.o2Min}",
                    data.oxygen < data.o2Min ? Colors.red : Colors.blue[900]!),
                _sensorItem("Temp", data.temp.toString(), "°C", "Max: ${data.tempMax}",
                    data.temp > data.tempMax ? Colors.orange : Colors.blue[900]!),
                _sensorItem("pH", data.ph.toString(), "pH", "${data.phMin}-${data.phMax}",
                    (data.ph < data.phMin || data.ph > data.phMax) ? Colors.red : Colors.blue[900]!),
              ],
            ),

            const Divider(height: 40),

            // --- AI INSIGHT CARD (PREV, CURRENT, NEW GOAL) ---
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue[100]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.psychology, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      const Text("AI ANALYSIS SYSTEM", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      if (pondProvider.isOptimizing)
                        const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _storyText("CURRENT CONDITION", data.currentCondition, Colors.black87),
                  const SizedBox(height: 8),
                  _storyText("NEW GOAL", data.newGoal, Colors.blue[900]!, isBold: true),
                  const SizedBox(height: 8),
                  _storyText("PREVIOUS FOCUS", data.prevFocus, Colors.grey),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => pondProvider.triggerAiOptimization(),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], shape: const StadiumBorder()),
                      child: const Text("Manual Optimize", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // AI Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("AI Automation Mode", style: TextStyle(fontWeight: FontWeight.w500)),
                Switch(
                  value: data.isAi,
                  onChanged: (val) => pondProvider.toggleAiMode(val),
                  activeColor: Colors.blue[800],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _sensorItem(String label, String val, String unit, String limit, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        Text(unit, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
          child: Text(limit, style: const TextStyle(fontSize: 9, color: Colors.black54)),
        ),
      ],
    );
  }

  Widget _storyText(String label, String content, Color textColor, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black54)),
        Text(content, style: TextStyle(fontSize: 13, color: textColor, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }
}