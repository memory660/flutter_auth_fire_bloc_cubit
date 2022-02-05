import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<dynamic> getRequest(String url) async {
    http.Response response = await http.get(Uri.parse(url));
    print(response.statusCode);
    switch (response.statusCode) {
      case 200:
        String jsonData = response.body;
        var decodeData = jsonDecode(jsonData);
        return decodeData;
        break;
      default:
        return "Error occurred during api connection";
    }
  }
}
