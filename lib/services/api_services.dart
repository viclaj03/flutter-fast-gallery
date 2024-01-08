import 'dart:convert';

import 'package:fastgalery/model/post.dart';
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
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar la lista de imágenes');
    }
  }


  Future<String> getImageListByFollowing(int page) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/image/get-following-post?page=$page'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar la lista de imágenes');
    }
  }


  Future<String> getImageListSearch(int page,String search) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/image/search?page=$page&search_content=$search'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar la Imagen');
    }
  }




  Future<String> getImageListLike(int page) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/image/get-favorites?page=$page'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar la Imagen');
    }
  }


  Future<String> getImageListUser(int page,int user) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/image/user-post/$user?page=$page'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar la Imagen');
    }
  }





  Future<String> getImage(int id) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/image/get/$id'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar la Imagen');
    }
  }



  Future<String> deleteImage(int id) async {

    final token = await getToken();
    final response = await http.delete(Uri.parse('$baseUrl/image/$id'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al borrar la imaegen');
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


  Future<String> getUserProfile(int id) async {
    Map<String, String> baseHeaders;
    final token = await getToken();
    if(token == null){
      throw Exception('Usuario no logueado');
    }

    final response = await http.get(Uri.parse('$baseUrl/user/$id'),headers: {
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

  Future<String> reportPost(int id,String content) async{
    final token = await getToken();
    if(token == null){
      throw Exception('Usuario no logueado');
    }
    print('9999999999');
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "multipart/form-data",
    };
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/report/$id'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['content'] = content;

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseData);
      return parsedResponse.toString();
    } else {
      final responseData = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseData);
      print(parsedResponse);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Erroraa: No se pudo reportar');
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
      'tags':body['tags']
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







  Future<Map<String, dynamic>> updatePost( Map<String, dynamic> body, int id) async {
    final token = await getToken();
    var request =  http.MultipartRequest("PUT", Uri.parse('$baseUrl/image/$id'));

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "multipart/form-data",
    };

    request.headers.addAll(headers);
    request.fields.addAll({
      'title': body['title'],
      'description': body['description'],
      'NSFW': body['NSFW'].toString(),
      'tags':body['tags']
    });

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseData);
      return parsedResponse;
    } else {
      final responseData = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseData);
      print(parsedResponse);
      throw Exception('Error al actulizar el post \npruebe mas tarde');
    }
  }


  Future<bool> likePost(Post post) async{
    final token = await getToken();
    var request =  http.MultipartRequest("POST", Uri.parse('$baseUrl/image/add-favorite/${post.id}'));

    final headers = {
      "Authorization": "Bearer $token",
    };

    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseData);
      post.favorited_by_user = parsedResponse['actual_value'];
      return parsedResponse['actual_value'];
    } else {
      throw Exception('No se pudo ejecutar');
    }

  }


  Future<bool> followUser(int user_id) async{
    final token = await getToken();
    var request =  http.MultipartRequest("POST", Uri.parse('$baseUrl/user-follow/$user_id'));

    final headers = {
      "Authorization": "Bearer $token",
    };

    request.headers.addAll(headers);

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseData);
      return parsedResponse['actual_value'];
    } else {
      throw Exception('No se pudo ejecutar');
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

