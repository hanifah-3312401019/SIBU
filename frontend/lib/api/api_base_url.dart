class ApiBaseUrl {
  // Untuk emulator Android (AVD), localhost = 10.0.2.2
  // static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Untuk device fisik (HP real), pakai IP komputer
  // Cek IP dengan `ipconfig` → IPv4 Address: 192.168.88.15
  // static const String baseUrl = 'http://192.168.88.:8000/api';

  // Untuk development di Chrome (web)
  static const String baseUrl = 'http://localhost:8000/api';

  // Endpoints
  static const String login = '$baseUrl/login';
  static const String logout = '$baseUrl/logout';
  static const String me = '$baseUrl/me';
}
