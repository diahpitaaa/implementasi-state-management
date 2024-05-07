import 'package:flutter/material.dart'; // Import package untuk membuat UI Flutter
import 'package:http/http.dart' as http; // Import package untuk membuat HTTP requests
import 'dart:convert'; // Import package untuk mengonversi data
import 'package:provider/provider.dart'; // Import package untuk menggunakan Provider

void main() {
  runApp(MyApp());
}

// Model untuk merepresentasikan data universitas
class University {
  String name; // Nama universitas
  String alphaTwoCode; // Kode alpha dua universitas
  String country; // Negara universitas
  List<String> domains; // Daftar domain universitas
  List<String> webPages; // Daftar halaman web universitas

  // Constructor untuk membuat objek University
  University({
    required this.name,
    required this.alphaTwoCode,
    required this.country,
    required this.domains,
    required this.webPages,
  });

  // Factory method untuk membuat objek University dari data JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      alphaTwoCode: json['alpha_two_code'],
      country: json['country'],
      domains: List<String>.from(json['domains']),
      webPages: List<String>.from(json['web_pages']),
    );
  }
}

// Provider untuk mengelola state aplikasi dan data universitas
class UniversityProvider extends ChangeNotifier {
  late List<University> _universities; // Data universitas
  List<University> get universities => _universities; // Getter untuk data universitas

  // Method untuk mengambil data universitas dari API
  Future<void> fetchData(String country) async {
    String url = "http://universities.hipolabs.com/search?country=$country"; // URL API untuk mendapatkan data universitas
    final response = await http.get(Uri.parse(url)); // Melakukan HTTP GET request
    if (response.statusCode == 200) { // Jika respons berhasil
      Iterable list = json.decode(response.body); // Decode JSON menjadi list
      _universities = list.map((model) => University.fromJson(model)).toList(); // Mengubah list JSON menjadi list objek University
      notifyListeners(); // Memberitahu semua listener bahwa state telah berubah
    } else {
      throw Exception('Failed to load data'); // Jika gagal, lempar exception
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UniversityProvider(), // Membuat instance dari UniversityProvider
      child: MaterialApp(
        title: 'University Populations',
        home: UniversityList(), // Menggunakan widget UniversityList sebagai home screen
      ),
    );
  }
}

class UniversityList extends StatefulWidget {
  @override
  _UniversityListState createState() => _UniversityListState();
}

class _UniversityListState extends State<UniversityList> {
  late UniversityProvider _universityProvider; // Instance dari UniversityProvider
  String _selectedCountry = 'Indonesia'; // Negara default yang dipilih

  @override
  void initState() {
    super.initState();
    _universityProvider = Provider.of<UniversityProvider>(context, listen: false); // Mendapatkan instance UniversityProvider
    _universityProvider.fetchData(_selectedCountry); // Mengambil data universitas saat initState dipanggil
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('University Populations'),
      ),
      body: Center(
        child: Column(
          children: [
            // DropdownButton untuk memilih negara ASEAN
            DropdownButton<String>(
              value: _selectedCountry,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCountry = newValue!; // Update negara yang dipilih
                  _universityProvider.fetchData(_selectedCountry); // Ambil data universitas untuk negara yang baru dipilih
                });
              },
              // Item dropdown yang berisi daftar negara ASEAN
              items: <String>['Indonesia', 'Malaysia', 'Singapore', 'Thailand', 'Vietnam']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Consumer untuk mendengarkan perubahan pada UniversityProvider
            Consumer<UniversityProvider>(
              builder: (context, provider, child) {
                if (provider.universities.isEmpty) {
                  return CircularProgressIndicator(); // Menampilkan indicator jika data belum dimuat
                } else {
                  // ListView untuk menampilkan data universitas
                  return Expanded(
                    child: ListView.builder(
                      itemCount: provider.universities.length,
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${provider.universities[index].name}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text('Alpha Code: ${provider.universities[index].alphaTwoCode}'),
                                Text('Country: ${provider.universities[index].country}'),
                                Text('Domains: ${provider.universities[index].domains.join(', ')}'),
                                Text('Web Pages: ${provider.universities[index].webPages.join(', ')}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
