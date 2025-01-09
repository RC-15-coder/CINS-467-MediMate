import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SearchDrugsPage extends StatefulWidget {
  const SearchDrugsPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchDrugsPageState createState() => _SearchDrugsPageState();
}

class _SearchDrugsPageState extends State<SearchDrugsPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _drugInfo = {};
  bool _isLoading = false;

  Future<void> searchDrug(String query) async {
    setState(() => _isLoading = true);
    final String apiUrl =
        'https://api.fda.gov/drug/label.json?search=spl_product_data_elements:$query&limit=5';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        //print('Data is : $data');
        if (data['results'] != null && data['results'].isNotEmpty) {
          Map<String, dynamic> extractedInfo = {};
          extractedInfo.addAll(data['results'][0]); 
          for (int i = 1; i < (data['results']).length; i++) {
            if (data['results'][i]['openfda'] != null &&
                data['results'][i]['openfda'].isNotEmpty) {
              extractedInfo.remove('openfda');
              var openfda = data['results'][i]['openfda'];
              extractedInfo.putIfAbsent('openfda', () => openfda);
              break;
            }
          }
          setState(() {
            _drugInfo = extractedInfo;
          });
        } else {
          setState(() => _drugInfo = {});
        }
        } else {
          setState(() => _drugInfo = {});
        }
      } catch (e) {
        setState(() => _drugInfo = {});
      } finally {
        setState(() => _isLoading = false);
      }
    }

  @override
  Widget build(BuildContext context) {
    double scaleFactor = MediaQuery.of(context).size.width / 375;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Drugs',
        style: TextStyle(
        fontWeight: FontWeight.bold, 
        ),
        ),
        backgroundColor: Colors.teal[600],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.0 * scaleFactor, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon:
                            const Icon(Icons.search, color: Color.fromARGB(255, 40, 150, 240)),
                        hintText: 'Enter a drug name',
                        suffix: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.black),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _drugInfo = {});
                              },
                            ),
                            const SizedBox(
                              height: 20,
                              child: VerticalDivider(color: Colors.black),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_controller.text.isNotEmpty) {
                                  searchDrug(_controller.text);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: const Text(
                                  'Search',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                              color: Colors.indigo.shade900, width: 3),
                        ),
                      ),
                      style: TextStyle(fontSize: 18 * scaleFactor),
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          searchDrug(value);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0 * scaleFactor),
            if (_isLoading) const CircularProgressIndicator(),
            if (_drugInfo.isNotEmpty) _buildDrugInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrugInfo() {
    List<Widget> infoWidgets = [];

    void addInfoSection(String title, List<dynamic>? info) {
      if (info != null && info.isNotEmpty) {
        infoWidgets.add(_buildInfoSection(title, info));
      }
    }

    void addSimpleInfoSection(String title, dynamic info) {
      if (info != null && info.isNotEmpty) {
        infoWidgets.add(_buildSimpleInfoSection(title, info));
      }
    }

    addInfoSection('Active Ingredients', _drugInfo['active_ingredient']);
    addSimpleInfoSection(
        'Generic Name', (_drugInfo['openfda']?['generic_name'] as List?)?.join(', '));
    addSimpleInfoSection(
        'Product Type', (_drugInfo['openfda']?['product_type'] as List?)?.join(', '));
    addSimpleInfoSection('Route', (_drugInfo['openfda']?['route'] as List?)?.join(', '));
    addInfoSection('Purpose', _drugInfo['purpose']);
    addInfoSection('Uses', _drugInfo['indications_and_usage']);
    addInfoSection('Warnings', _drugInfo['warnings']);
    addInfoSection('Do Not Use', _drugInfo['do_not_use']);
    addInfoSection('Ask a Doctor', _drugInfo['ask_doctor']);
    addInfoSection(
        'Ask a Doctor or Pharmacist', _drugInfo['ask_doctor_or_pharmacist']);
    addInfoSection('Stop Use', _drugInfo['stop_use']);
    addInfoSection('Pregnancy or Breast Feeding',
        _drugInfo['pregnancy_or_breast_feeding']);
    addInfoSection('Keep Out of Reach of Children',
        _drugInfo['keep_out_of_reach_of_children']);
    addInfoSection(
        'Dosage and Administration', _drugInfo['dosage_and_administration']);
    addInfoSection('Storage and Handling', _drugInfo['storage_and_handling']);
    addInfoSection('Inactive Ingredients', _drugInfo['inactive_ingredient']);

    return Container(
      color: Colors.teal[600],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: infoWidgets,
      ),
    );
  }

  Widget _buildInfoSection(String title, List<dynamic>? info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 8, 8, 8),
              fontWeight: FontWeight.bold,
              fontSize: 19,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            info?.join(", ") ?? "N/A",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleInfoSection(String title, String? info) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color.fromARGB(255, 8, 8, 8),
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            info ?? "N/A",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
