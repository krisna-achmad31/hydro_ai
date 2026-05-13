import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/pond_model.dart';

class PondProvider with ChangeNotifier {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref('sandbox');
  PondData? _data;
  bool _isLoading = true;
  bool _isOptimizing = false;
  DateTime? _lastAiTriggerTime;

  PondData? get data => _data;
  bool get isLoading => _isLoading;
  bool get isOptimizing => _isOptimizing;

  PondProvider() {
    _initListener();
  }

  void _initListener() {
    _dbRef.onValue.listen((event) {
      final map = event.snapshot.value as Map<dynamic, dynamic>?;
      if (map != null) {
        _data = PondData.fromMap(map);
        _isLoading = false;

        // --- LOGIKA AI PINTAR: HANYA TRIGGER JIKA LEWAT LIMITS ---
        if (_data!.isAi && !_isOptimizing) {
          bool isO2Low = _data!.oxygen < _data!.o2Min;
          bool isTempHigh = _data!.temp > _data!.tempMax;
          bool isPhOut = (_data!.ph < _data!.phMin || _data!.ph > _data!.phMax);

          if (isO2Low || isTempHigh || isPhOut) {
            final now = DateTime.now();
            if (_lastAiTriggerTime == null || now.difference(_lastAiTriggerTime!).inMinutes >= 1) {
              _lastAiTriggerTime = now;
              triggerAiOptimization();
            }
          }
        }
        notifyListeners();
      }
    });
  }

  final models = [
    "meta-llama/llama-3.3-70b-instruct:free",
    "deepseek/deepseek-r1:free",
    "meta-llama/llama-3.2-3b-instruct:free",
    "meta-llama/llama-3-70b-instruct",
    "Qwen3.5-35B-A3B"
  ];

  Future<void> triggerAiOptimization() async {
    if (_isOptimizing || _data == null) return;

    _isOptimizing = true;
    notifyListeners();

    final apiKey = dotenv.env['OPENROUTER_API_KEY'] ?? '';
    const url = 'https://openrouter.ai/api/v1/chat/completions';

    // 1. SYSTEM PROMPT: SAKLEK SESUAI KESEPAKATAN
    String systemPrompt = """
You are a specialized IoT Logic Engine for HydroNeo.
Current Animal Type: ${_data!.animalType}. 
Standardize your analysis and limits based on the biological needs of this specific animal.
Output MUST be a single, valid JSON object. NO PROSE.

REQUIRED JSON STRUCTURE:
{
  "analysis": {
    "prev_focus": "string",
    "current_condition": "string",
    "new_goal": "string"
  },
  "limits": {
    "o2_min": float,
    "temp_max": float,
    "ph_min": float,
    "ph_max": float
  },
  "lua_script": "string"
}

LUA RULES:
1. Use 'e.oxygen', 'e.temp', 'e.ph'. (NEVER USE e.temperature).
2. Minified style (no extra spaces).
3. Always include 'ASSISTANT: ACTING' or 'ASSISTANT: IDLE' in displayShow.
4. lua_script must be a single line.
""";

    // 2. FEW-SHOT EXAMPLE (Kunci Konsistensi)
    String exampleUser = "SENSOR: O2:4.5, Temp:32.0. LIMITS: O2Min:5.0, TempMax:30.0.";
    String exampleAssistant = "{\"analysis\":{\"prev_focus\":\"Monitoring\",\"current_condition\":\"Critical O2 drop and heat spike\",\"new_goal\":\"Emergency aeration\"},\"limits\":{\"o2_min\":6.0,\"temp_max\":33.0,\"ph_min\":7.5,\"ph_max\":8.5},\"lua_script\":\"function process(e)if e.is_ai==1 then if e.oxygen<6.0 then setHardware(18,1)displayShow(\\\"ASSISTANT: ACTING\\\",\\\"O2 LOW! OPENING\\\")else setHardware(18,0)displayShow(\\\"ASSISTANT: IDLE\\\",\\\"Safe\\\")end else displayShow(\\\"MANUAL\\\",e.manual_sw==1 and \\\"ON\\\" or \\\"OFF\\\")setHardware(18,e.manual_sw)end end\"}";


    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "model": models[3],
          "messages": [
            {"role": "system", "content": systemPrompt},
            {"role": "user", "content": exampleUser},
            {"role": "assistant", "content": exampleAssistant},
            {
              "role": "user",
              "content": "ANIMAL: ${_data!.animalType}. Analyze: O2:${_data!.oxygen}, Temp:${_data!.temp}, pH:${_data!.ph}. Prev Goal: ${_data!.newGoal}."
            }
          ],
          "temperature": 0.1,
        }),
      );
      print("AI RESPONSE STATUS: ${response.body}");

      if (response.statusCode == 200) {
        String rawResponse = jsonDecode(response.body)['choices'][0]['message']['content'];
        rawResponse = rawResponse.replaceAll(RegExp(r'```json|```'), '').trim();

        final Map<String, dynamic> aiBrain = jsonDecode(rawResponse);

        // --- UPDATE FIREBASE (STRICT MAPPING) ---

        // Update Analysis
        await _dbRef.child('analysis').update({
          'prev_focus': _data!.newGoal,
          'current_condition': aiBrain['analysis']['current_condition']?.toString() ?? "-",
          'new_goal': aiBrain['analysis']['new_goal']?.toString() ?? "-",
        });

        // Update Limits (Sesuai REQUIRED STRUCTURE)
        final lim = aiBrain['limits'] ?? {};
        await _dbRef.child('limits').update({
          'o2_min': (lim['o2_min'] ?? _data!.o2Min).toDouble(),
          'temp_max': (lim['temp_max'] ?? _data!.tempMax).toDouble(),
          'ph_min': (lim['ph_min'] ?? _data!.phMin).toDouble(),
          'ph_max': (lim['ph_max'] ?? _data!.phMax).toDouble(),
        });

        // Update LUA Script
        await _dbRef.child('logic').set(aiBrain['lua_script']?.toString() ?? "");

        // Update Metadata
        await _dbRef.child('metadata/last_update').set(DateTime.now().toIso8601String());

        print("!!! AI BRAIN SAKLEK UPDATED !!!");
      }
    } catch (e) {
      debugPrint("CRITICAL AI ERROR: $e");
    } finally {
      _isOptimizing = false;
      notifyListeners();
    }
  }

  Future<void> toggleAiMode(bool val) async {
    await _dbRef.child('inputs/is_ai').set(val ? 1 : 0);
  }
}