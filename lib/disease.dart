import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class DiseaseCondition {
  final String keyId;
  final String primaryName;
  final List<String> infoLinks;

  DiseaseCondition({required this.keyId, required this.primaryName, required this.infoLinks});

  factory DiseaseCondition.fromJson(Map<String, dynamic> json) {
    List<String> links = (json['info_link_data'] as List).map((item) => item[0] as String).toList();
    return DiseaseCondition(
      keyId: json['key_id'],
      primaryName: json['primary_name'],
      infoLinks: links,
    );
  }
}

Future<List<DiseaseCondition>> loadConditions() async {
  String jsonString = await rootBundle.loadString('assets/conditions.json');
  List<dynamic> jsonResponse = json.decode(jsonString);
  return jsonResponse.map((item) => DiseaseCondition.fromJson(item)).toList();
}

Future<List<DiseaseCondition>> searchConditionsByLetter(String letter) async {
  List<DiseaseCondition> allConditions = await loadConditions();
  return allConditions.where((condition) => condition.primaryName.startsWith(letter)).toList();
}