import 'package:flutter/material.dart'; // Import package untuk membuat UI Flutter
import 'package:flutter_bloc/flutter_bloc.dart'; // Import package untuk Flutter Bloc
import 'package:http/http.dart' as http; // Import package untuk membuat HTTP requests
import 'dart:convert'; // Import package untuk mengonversi data

// Membuat event untuk fetching data universitas berdasarkan negara
abstract class UniversityEvent {}

class FetchUniversities extends UniversityEvent {
  final String country;

  FetchUniversities(this.country);
}

// Membuat state untuk menampung data universitas
class UniversityState {
  final List<UnivPage> universities;

  UniversityState(this.universities);
}

// Membuat Cubit untuk mengatur state dan event untuk data universitas
class UniversityCubit extends Cubit<UniversityState> {
  UniversityCubit() : super(UniversityState([]));

  // Method untuk melakukan fetching data universitas berdasarkan negara
  Future<void> fetchUniversities(String country) async {
    final response = await http.get(Uri.parse("http://universities.hipolabs.com/search?country=$country")); // Lakukan HTTP GET request berdasarkan negara
    if (response.statusCode == 200) { // Jika respons berhasil
      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<UnivPage> universities = jsonData.map((json) => UnivPage.fromJson(json)).toList();
      emit(UniversityState(universities)); // Update state dengan data universitas yang baru didapat
    } else {
      throw Exception('Failed to load data'); // Jika gagal, lempar exception
    }
  }
}

// Widget utama aplikasi
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Populations',
      home: BlocProvider(
        create: (context) => UniversityCubit(),
        child: UniversityScreen(),
      ),
    );
  }
}

class UniversityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universityCubit = BlocProvider.of<UniversityCubit>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('University Populations'),
      ),
      body: UniversityList(),
    );
  }
}

class UniversityList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final universityCubit = BlocProvider.of<UniversityCubit>(context);

    return BlocBuilder<UniversityCubit, UniversityState>(
      builder: (context, state) {
        return Column(
          children: [
            DropdownButton<String>(
              value: state.universities.isNotEmpty ? state.universities[0].country : 'Indonesia', // Nilai terpilih pada combobox
              onChanged: (String? newValue) {
                if (newValue != null) {
                  universityCubit.fetchUniversities(newValue);
                }
              },
              items: _countries.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.universities.length,
                itemBuilder: (context, index) {
                  return UniversityCard(university: state.universities[index]);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class UniversityCard extends StatelessWidget {
  final UnivPage university;

  UniversityCard({required this.university});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5, // Atur elevasi kartu
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Atur margin kartu
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Atur penempatan teks ke kiri
          children: [
            Text(
              'Name: ${university.name}', // Tampilkan nama universitas
              style: TextStyle(fontWeight: FontWeight.bold), // Teks bold
            ),
            SizedBox(height: 8), // Buat jarak vertikal antara teks
            Text('Alpha Code: ${university.alphaTwoCode}'), // Tampilkan kode alpha dua universitas
            Text('Country: ${university.country}'), // Tampilkan negara universitas
            Text('Domains: ${university.domains.join(', ')}'), // Tampilkan daftar domain universitas
            Text('Web Pages: ${university.webPages.join(', ')}'), // Tampilkan daftar halaman web universitas
          ],
        ),
      ),
    );
  }
}

// Model untuk menyimpan data universitas
class UnivPage {
  String name; // Atribut untuk menampung nama universitas
  String alphaTwoCode; // Atribut untuk menampung kode alpha dua universitas
  String country; // Atribut untuk menampung negara universitas
  List<String> domains; // Atribut untuk menampung daftar domain universitas
  List<String> webPages; // Atribut untuk menampung daftar halaman web universitas

  // Constructor untuk inisialisasi objek UnivPage
  UnivPage({required this.name, required this.alphaTwoCode, required this.country, required this.domains, required this.webPages});

  // Method untuk mengonversi data JSON ke objek UnivPage
  factory UnivPage.fromJson(Map<String, dynamic> json) {
    return UnivPage(
      name: json["name"],
      alphaTwoCode: json["alpha_two_code"],
      country: json["country"],
      domains: List<String>.from(json["domains"]),
      webPages: List<String>.from(json["web_pages"]),
    );
  }
}

// Daftar negara ASEAN
List<String> _countries = ['Indonesia', 'Malaysia', 'Singapore', 'Thailand', 'Vietnam'];