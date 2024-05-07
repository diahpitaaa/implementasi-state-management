import 'dart:async'; // Import library async untuk menggunakan StreamController
import 'package:flutter/material.dart'; // Import library flutter untuk pengembangan UI
import 'package:http/http.dart' as http; // Import library http untuk melakukan HTTP requests
import 'dart:convert'; // Import library convert untuk mengonversi data

class UnivPage { // Deklarasi class UnivPage untuk merepresentasikan halaman universitas
  String name; // Deklarasi atribut name bertipe String untuk menampung nama universitas
  String alphaTwoCode; // Deklarasi atribut alphaTwoCode bertipe String untuk menampung kode alpha dua universitas
  String country; // Deklarasi atribut country bertipe String untuk menampung negara universitas
  List<String> domains; // Deklarasi atribut domains bertipe List<String> untuk menampung daftar domain universitas
  List<String> webPages; // Deklarasi atribut webPages bertipe List<String> untuk menampung daftar halaman web universitas

  // Constructor untuk inisialisasi objek UnivPage
  UnivPage({required this.name, required this.alphaTwoCode, required this.country, required this.domains, required this.webPages});
}

class UnivBloc { // Deklarasi class UnivBloc untuk mengelola logika bisnis terkait data universitas
  late StreamController<List<UnivPage>> _univController; // Deklarasi StreamController untuk mengirim data universitas ke widget
  Stream<List<UnivPage>> get univStream => _univController.stream; // Getter untuk mendapatkan stream data universitas

  UnivBloc() { // Constructor untuk inisialisasi objek UnivBloc
    _univController = StreamController<List<UnivPage>>(); // Inisialisasi StreamController
  }

  fetchData(String country) async { // Method untuk mengambil data universitas dari API berdasarkan negara
    final response = await http.get(Uri.parse("http://universities.hipolabs.com/search?country=$country")); // Lakukan HTTP GET request berdasarkan negara
    if (response.statusCode == 200) { // Jika respons berhasil
      List<UnivPage> univList = []; // Inisialisasi list untuk menampung data universitas
      List<dynamic> json = jsonDecode(response.body); // Konversi respons JSON ke dalam bentuk List<dynamic>
      for (var val in json) { // Looping untuk mengonversi data JSON ke objek UnivPage
        var name = val["name"]; // Ambil nilai name dari data JSON
        var alphaTwoCode = val["alpha_two_code"]; // Ambil nilai alpha_two_code dari data JSON
        var country = val["country"]; // Ambil nilai country dari data JSON
        var domains = List<String>.from(val["domains"]); // Ambil nilai domains dari data JSON dan konversi ke dalam List<String>
        var webPages = List<String>.from(val["web_pages"]); // Ambil nilai web_pages dari data JSON dan konversi ke dalam List<String>
        univList.add(UnivPage(name: name, alphaTwoCode: alphaTwoCode, country: country, domains: domains, webPages: webPages)); // Tambahkan objek UnivPage ke dalam list
      }
      _univController.sink.add(univList); // Kirim data universitas ke stream
    } else { // Jika respons gagal
      throw Exception('Failed to load data'); // Lemparkan exception
    }
  }

  dispose() { // Method untuk membersihkan resources saat tidak lagi diperlukan
    _univController.close(); // Tutup StreamController
  }
}

void main() { // Fungsi utama aplikasi
  runApp(MyApp()); // Jalankan aplikasi Flutter
}

class MyApp extends StatefulWidget { // Deklarasi class MyApp yang merupakan StatefulWidget
  @override
  State<StatefulWidget> createState() { // Method untuk membuat state dari MyApp
    return MyAppState(); // Kembalikan instance MyAppState
  }
}

class MyAppState extends State<MyApp> { // Deklarasi class MyAppState yang merupakan State dari MyApp
  late UnivBloc _univBloc; // Deklarasi UnivBloc sebagai state untuk mengelola data universitas
  String _selectedCountry = 'Indonesia'; // Deklarasi variabel _selectedCountry untuk menyimpan negara yang dipilih
  List<String> _countries = ['Indonesia', 'Malaysia', 'Singapore', 'Thailand', 'Vietnam']; // Deklarasi list _countries berisi negara-negara ASEAN

  @override
  void initState() { // Method yang dipanggil ketika state diinisialisasi
    super.initState(); // Panggil method initState dari superclass
    _univBloc = UnivBloc(); // Inisialisasi UnivBloc
    _univBloc.fetchData(_selectedCountry); // Ambil data universitas untuk negara Indonesia
  }

  @override
  void dispose() { // Method yang dipanggil saat state dihapus dari pohon widget
    _univBloc.dispose(); // Panggil method dispose dari UnivBloc untuk membersihkan resources
    super.dispose(); // Panggil method dispose dari superclass
  }

  @override
  Widget build(BuildContext context) { // Method untuk membangun UI aplikasi
    return MaterialApp( // Widget utama aplikasi
      title: 'University Populations', // Judul aplikasi
      home: Scaffold( // Scaffold sebagai kerangka utama aplikasi
        appBar: AppBar( // AppBar sebagai bagian atas aplikasi
          title: const Text('University Populations'), // Judul AppBar
        ),
        body: Center( // Widget body di tengah layar
          child: Column( // Widget kolom untuk menampilkan dropdown dan daftar universitas
            children: [
              DropdownButton<String>( // Widget dropdown untuk memilih negara
                value: _selectedCountry, // Nilai terpilih pada dropdown
                onChanged: (String? newValue) { // Callback saat nilai dropdown berubah
                  setState(() { // Panggil setState untuk merender ulang UI
                    _selectedCountry = newValue!; // Update nilai terpilih
                    _univBloc.fetchData(_selectedCountry); // Ambil data universitas untuk negara yang baru dipilih
                  });
                },
                items: _countries.map<DropdownMenuItem<String>>((String value) { // Daftar item dropdown
                  return DropdownMenuItem<String>(
                    value: value, // Nilai item dropdown
                    child: Text(value), // Teks item dropdown
                  );
                }).toList(),
              ),
              StreamBuilder<List<UnivPage>>( // Widget untuk menampilkan daftar universitas
                stream: _univBloc.univStream, // Stream data universitas dari UnivBloc
                builder: (context, snapshot) { // Callback untuk membangun UI dari data stream
                  if (snapshot.connectionState == ConnectionState.waiting) { // Jika sedang dalam proses pemrosesan
                    return CircularProgressIndicator(); // Tampilkan indicator loading
                  } else if (snapshot.hasError) { // Jika terjadi error
                    return Text('Error: ${snapshot.error}'); // Tampilkan pesan error
                  } else { // Jika data tersedia
                    return Expanded( // Widget Expanded agar daftar universitas dapat menyesuaikan ukuran layar
                      child: ListView.builder( // Widget ListView untuk menampilkan daftar universitas
                        itemCount: snapshot.data!.length, // Jumlah item dalam daftar
                        itemBuilder: (context, index) { // Callback untuk membangun item dalam daftar
                          return Card( // Widget Card untuk menampilkan informasi universitas
                            elevation: 5, // Tingkat elevasi kartu
                            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Margin kartu
                            child: Padding( // Widget Padding untuk memberikan padding dalam kartu
                              padding: const EdgeInsets.all(16.0), // Padding semua sisi
                              child: Column( // Widget kolom untuk menampilkan informasi universitas
                                crossAxisAlignment: CrossAxisAlignment.start, // Penempatan teks ke kiri
                                children: [
                                  Text( // Teks untuk menampilkan nama universitas
                                    'Name: ${snapshot.data![index].name}', // Nilai teks
                                    style: TextStyle(fontWeight: FontWeight.bold), // Gaya teks tebal
                                  ),
                                  SizedBox(height: 8), // Jarak vertikal antara teks
                                  Text('Alpha Code: ${snapshot.data![index].alphaTwoCode}'), // Teks untuk menampilkan kode alpha dua universitas
                                  Text('Country: ${snapshot.data![index].country}'), // Teks untuk menampilkan negara universitas
                                  Text('Domains: ${snapshot.data![index].domains.join(', ')}'), // Teks untuk menampilkan daftar domain universitas
                                  Text('Web Pages: ${snapshot.data![index].webPages.join(', ')}'), // Teks untuk menampilkan daftar halaman web universitas
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
      ),
    );
  }
}
