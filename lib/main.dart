import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'disease.dart';
import 'location.dart';
import 'drugs.dart';
import 'login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  
  );
  runApp(const MedimateApp());
}

class MedimateApp extends StatelessWidget {
  const MedimateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medimate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginSignupPage(),  
      routes: {
        '/home': (context) => const HomePage(userName: '',),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final String userName;
  const HomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
        'Medimate',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25, 
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff008083), 
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/medimate bgm.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome $userName',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 4, 4),
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black45,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10), 
              const Text(
                'Your Health Guide',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 4, 4),
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black45,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40), 
              buttonSection(context, 'Search Drugs', Icons.medical_services, () => _navigateTo(context, const SearchDrugsPage())),
              buttonSection(context, 'Search Diseases', Icons.healing, () => _navigateTo(context, const SearchDiseasesPage())),
              buttonSection(context, 'Nearby Healthcare', Icons.local_hospital, () => _navigateTo(context, const NearbyPharmacyPage())),
              buttonSection(context, 'Login/Signup', Icons.login, () => _navigateTo(context, const LoginSignupPage())), 
            ],
          ),
        ),
      ),
    );
  }

  Widget buttonSection(BuildContext context, String text, IconData icon, VoidCallback onPressed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Colors.lightBlueAccent[400],
          elevation: 10.0,
          child: Icon(icon, size: 30.0, color: Colors.white),
        ),
        const SizedBox(height: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black45,
                offset: Offset(1.0, 1.0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

class SearchDiseasesPage extends StatefulWidget {
  const SearchDiseasesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SearchDiseasesPageState createState() => _SearchDiseasesPageState();
}

class _SearchDiseasesPageState extends State<SearchDiseasesPage> {
  final TextEditingController _controller = TextEditingController();
  String? _infoLink;
  bool _isLoading = false;
  List<DiseaseCondition> filteredConditions = [];
  String selectedLetter = ''; 
  Future<void> searchDiseases(String query) async {
    setState(() => _isLoading = true);
    final String apiUrl =
        'https://clinicaltables.nlm.nih.gov/api/conditions/v3/search?terms=$query&ef=info_link_data';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data[2] != null && data[2].isNotEmpty) {
          setState(() {
            _infoLink = data[2]["info_link_data"][0][0][0];
          });
        } else {
          setState(() => _infoLink = null);
        }
      } else {
        setState(() => _infoLink = null);
      }
      } catch (e) {
        setState(() => _infoLink = null);
      } finally {
        setState(() => _isLoading = false);
      }
    }

  void handleSearch(String letter) {
    searchConditionsByLetter(letter).then((results) {
      setState(() {
        filteredConditions = results;
        selectedLetter = letter;
      });
    });
  }

  void _launchURL(String urlStr) async {
    print('urlStr: $urlStr');
    Uri url = Uri.parse(urlStr);

    print('url: $url');

    if (!await launchUrl(url)) {
      if (kDebugMode) {
        print('Could not launch $url');
      }
      throw 'Could not launch $url';
    }

  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double scaleFactor = screenWidth / 375;
    int crossAxisCount = 8;
    double buttonPadding = screenWidth / (crossAxisCount * 8);
    double spaceBetweenGridAndText = 32.0 * scaleFactor; 

    return Scaffold(
      backgroundColor: Colors.teal[700],
      appBar: AppBar(
        title: const Text(
        'Diseases & Conditions',
        style: TextStyle(
        fontWeight: FontWeight.bold, 
        ),
      ),
        backgroundColor: Colors.teal[700],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(18.0 * scaleFactor, 8.0 * scaleFactor, 18.0 * scaleFactor, 0),
              child: Text(
                'Easy-to-understand answers about diseases and conditions',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16 * scaleFactor,
                ),
              ),
            ),
            SizedBox(height: 6.0 * scaleFactor),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0 * scaleFactor),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search, color: Colors.black),
                  hintText: 'Search diseases',
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          _controller.clear();
                          setState(() => _infoLink = null);
                        },
                      ),
                      const SizedBox(
                        height: 20,
                        child: VerticalDivider(color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (_controller.text.isNotEmpty) {
                            searchDiseases(_controller.text);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: const Text(
                            'Search',
                            style: TextStyle(
                              color: Colors.black,
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
                    borderSide: const BorderSide(color: Colors.blue, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: Colors.indigo.shade900, width: 3),
                  ),
                ),
                style: TextStyle(color: Colors.black, fontSize: 18 * scaleFactor),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    searchDiseases(value);
                  }
                },
              ),
            ),
            SizedBox(height: 16.0 * scaleFactor),
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            if (_infoLink != null)
              Center(
                child: ElevatedButton(
                  onPressed: () => _launchURL(_infoLink!),
                  child: const Text('Go to Information Page'),
                ),
              ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0 * scaleFactor),
              child: Text(
                'Find diseases & conditions by first letter',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16 * scaleFactor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16.0 * scaleFactor),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.0 * scaleFactor),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1,
                crossAxisSpacing: 10.0 * scaleFactor,
                mainAxisSpacing: 10.0 * scaleFactor,
              ),
              itemCount: 26,
              itemBuilder: (context, index) {
                String letter = String.fromCharCode(index + 65);
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedLetter = letter;
                    });
                    handleSearch(letter);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.blue[900], shape: const CircleBorder(),
                    padding: EdgeInsets.all(buttonPadding),
                  ),
                  child: Text(
                    letter,
                    style: TextStyle(
                      fontSize: 14 * scaleFactor,
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: spaceBetweenGridAndText), 
            if (selectedLetter.isNotEmpty)
              Container(
                color: Colors.lightBlue[900],
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0 * scaleFactor),
                      child: Text(
                        'Diseases starting with letter $selectedLetter',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18 * scaleFactor,
                        ),
                      ),
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: filteredConditions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            filteredConditions[index].primaryName,
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          onTap: () => _launchURL(filteredConditions[index].infoLinks.first),
                        );
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}




