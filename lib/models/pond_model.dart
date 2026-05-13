class PondData {
  // Pilar 1: Inputs
  final double oxygen, temp, ph;
  final bool isAi, manualSw;

  // Pilar 2: Limits
  final double o2Min, tempMax, phMin, phMax;

  // Pilar 3: Analysis
  final String prevFocus, currentCondition, newGoal;

  // Pilar 4: Metadata
  final String lastUpdate;
  final double weatherMin, weatherMax;
  final int weatherRain, activePonds, totalPonds;
  final String animalType;

  PondData({
    required this.oxygen, required this.temp, required this.ph,
    required this.isAi, required this.manualSw,
    required this.o2Min, required this.tempMax, required this.phMin, required this.phMax,
    required this.prevFocus, required this.currentCondition, required this.newGoal,
    required this.lastUpdate, required this.weatherMin, required this.weatherMax,
    required this.weatherRain, required this.activePonds, required this.totalPonds,required this.animalType,
  });

  factory PondData.fromMap(Map<dynamic, dynamic> map) {
    // PROTEKSI: Jika node utama null, ganti dengan Map kosong agar tidak crash
    final i = map['inputs'] as Map? ?? {};
    final l = map['limits'] as Map? ?? {};
    final a = map['analysis'] as Map? ?? {};
    final m = map['metadata'] as Map? ?? {};

    return PondData(
      // Handling Double (Gunakan .toDouble() dengan fallback 0.0)
      oxygen: (i['oxygen'] ?? 0.0).toDouble(),
      temp: (i['temp'] ?? 0.0).toDouble(),
      ph: (i['ph'] ?? 0.0).toDouble(),

      // Handling Boolean/Int Toggle
      isAi: (i['is_ai'] ?? 0) == 1,
      manualSw: (i['manual_sw'] ?? 0) == 1,

      // Handling Limits
      o2Min: (l['o2_min'] ?? 0.0).toDouble(),
      tempMax: (l['temp_max'] ?? 0.0).toDouble(),
      phMin: (l['ph_min'] ?? 0.0).toDouble(),
      phMax: (l['ph_max'] ?? 0.0).toDouble(),

      // Handling Strings
      prevFocus: a['prev_focus']?.toString() ?? "-",
      currentCondition: a['current_condition']?.toString() ?? "-",
      newGoal: a['new_goal']?.toString() ?? "-",

      // Handling Metadata
      lastUpdate: m['last_update']?.toString() ?? "-",
      weatherMin: (m['weather_min'] ?? 0.0).toDouble(),
      weatherMax: (m['weather_max'] ?? 0.0).toDouble(),

      // FIX ERROR 'int': Gunakan fallback 0 sebelum diconvert
      weatherRain: int.tryParse(m['weather_rain']?.toString() ?? '0') ?? 0,
      activePonds: int.tryParse(m['active_ponds']?.toString() ?? '0') ?? 0,
      totalPonds: int.tryParse(m['total_ponds']?.toString() ?? '0') ?? 0,
      animalType: m['animal_type']?.toString() ?? "General",
    );
  }
}