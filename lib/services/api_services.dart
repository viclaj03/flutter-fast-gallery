import 'dart:convert';

import 'package:fastgalery/providers/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:image_picker/image_picker.dart';


class ApiService {
  final String baseUrl = "http://192.168.1.148:8000" ;
  ApiService();
  Future<String> getImageList(int page) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/image/?page=$page'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar la lista de imágenes');
    }
  }


  Future<String> getMyUser() async {
    Map<String, String> baseHeaders;
    final token = await getToken();
    if(token == null){
      throw Exception('Usuario no logueado');
    }

    final response = await http.get(Uri.parse('$baseUrl/users/me'),headers: {
      'Authorization': 'Bearer ' + token,
    });
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Sesion Caducada ');
    }
  }


  Future<Map<String, dynamic>> postImage( Map<String, dynamic> body,XFile file) async {
    final token = await getToken();
    var request =  http.MultipartRequest("POST", Uri.parse('$baseUrl/image/'));//?title=${body['title']}&description=${body['description']}&NSFW=true',));

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "multipart/form-data",
    };

    request.headers.addAll(headers);
    request.fields.addAll({
      'title': body['title'],
      'description': body['description'],
      'NSFW': body['NSFW'].toString(),
    });



    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: new MediaType('application', 'x-tar'),
    ));


    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseData);
      return parsedResponse;
    } else {
      throw Exception('Error al subir la imagen \npruebe mas tarde');
    }
  }
}



  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final String responseBody = response.body;
    final int statusCode = response.statusCode;

    if (statusCode < 200 || statusCode >= 400 || responseBody == null || responseBody.isEmpty) {
      throw Exception('Error de red: $statusCode');
    }

    try {
      final Map<String, dynamic> data = json.decode(responseBody);
      return data;
    } catch (e) {
      throw Exception('Error al decodificar la respuesta');
    }
  }

