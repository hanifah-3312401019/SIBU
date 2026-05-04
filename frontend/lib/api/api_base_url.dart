class ApiBaseUrl {
  // Untuk emulator Android (AVD), localhost = 10.0.2.2
  // static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Untuk device fisik (HP real), pakai IP komputer
  // Cek IP dengan `ipconfig` → IPv4 Address: 192.168.1.6
  // static const String baseUrl = 'http://192.168.1.6:8000/api';
  
  // Untuk development di Chrome (web)
  static const String baseUrl = 'http://localhost:8000/api';
}