import 'dart:convert';

import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/model/user.dart';
import 'package:fastgalery/providers/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:image_picker/image_picker.dart';


class ApiService {
  final String baseUrl = "http://192.168.1.136:8000" ;
  ApiService();


  Future<String> authenticateUser(String email, String password) async {

    final response = await http.post(
        Uri.parse('${baseUrl}/login'),
        body:{

          'username': email,
          'password': password,
        }
    );

    if (response.statusCode == 200) {
      final token =  json.decode(response.body);
      await saveToken(token['access_token']);



      String userData = await getMyUser();
      await saveIdUser(json.decode(userData)['id']);
      await saveEmail(json.decode(userData)['email']);
      await saveUsername(json.decode(userData)['name']);

      return userData;
    } else {

      // Si la solicitud falla, lanza una excepción
      throw Exception('Error de autentificación T.T');
    }
  }

  Future<int> resgistreUser({required String email,required String username,required String password}) async {

    final response = await http.post(
      Uri.parse('http://192.168.1.136:8000/registre'),

      body: {
        'email': email,
        'name': username,
        'password': password,
      },
    );


    if (response.statusCode == 200) {
      final token =  json.decode(response.body);
      await saveToken(token['access_token']);
      await saveIdUser(token['id']);
      print(response.body);
      return token['id'];
    } else {
      final respuesta =  json.decode(response.body);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error de autenticación T.T ${respuesta['detail']}');
    }
  }






  Future<String> forgotPassword({required String email}) async {

    final response = await http.post(
      Uri.parse('${baseUrl}/forgot-password'),

      body: {
        'email': email,
      },
    );


    if (response.statusCode == 200) {
      final mensaje =  json.decode(utf8.decode(response.body.codeUnits))['message'];
      return mensaje;
    } else {
      final respuesta =  json.decode(response.body);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error: ${respuesta['detail']}');
    }
  }


  Future<String> newPassword({required String email,required String code,required String password}) async {

    final response = await http.post(
      Uri.parse('${baseUrl}/reset-password'),

      body: {
        'email': email,
        'recovery_code': code,
        'password':password
      },
    );


    if (response.statusCode == 200) {
      final mensaje =  json.decode(utf8.decode(response.body.codeUnits))['message'];
      return mensaje;
    } else {
      final respuesta =  json.decode(response.body);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error: ${respuesta['detail']}');
    }
  }







  Future<List<User>> getSearchUserList(String filter) async {


    final response = await http.get(Uri.parse('$baseUrl/users-search?name=$filter'),headers: {

    });
    if (response.statusCode == 200) {
      List<dynamic> list = json.decode(utf8.decode(response.body.codeUnits));

      List<User> userList = list.map((e) => User.fromMap(e)).toList();

      return userList;
    } else {
      throw Exception('Error al cargar la lista de imágenes');
    }
  }


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



  Future<String> getMessageList(int page) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/get-messages-reciver/?page=$page'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar la lista de mensajes');
    }
  }

  Future<String> getSenderMessageList(int page) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/get-messages-sender/?page=$page'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar la lista de mensajes');
    }
  }




  Future<String> getMessage(int id) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/message/${id}'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar el mensaje');
    }
  }



  Future<String> deleteMessage(int id) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.delete(Uri.parse('$baseUrl/message/${id}'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al borrar el mensaje');
    }
  }



  Future<String> sendMessage(String title,String content,int receiverId) async {

    final token = await getToken();


    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final body = {
      'title': title,
      'content': content,
      'receiver_id':receiverId.toString()
    };


    final response = await http.post(Uri.parse('$baseUrl/send-message'),
        headers: headers,
        body:body );
    if (response.statusCode == 200) {
      return response.body;
    } else {
      print(response.body);
      throw Exception('Error al enviar el mensaje');
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



  Future<String> getMyPosts(int page) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/image/my-posts?page=$page'),headers: {
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





  Future<String> getPost(int id) async {
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



  Future<String> getComments(int id,int page) async {
    Map<String, String> baseHeaders;
    final token = await getToken();

    final response = await http.get(Uri.parse('$baseUrl/comments/$id?page=$page'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    print(response.statusCode);
    print(response.body);
    if (response.statusCode == 200) {

      return response.body;
    } else {
      throw Exception('Error al cargar los comentarios');
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

  Future<String> deleteComment(int id) async {
    final token = await getToken();
    final response = await http.delete(Uri.parse('$baseUrl/comments/$id'),headers: {
      'Authorization': 'Bearer ' + token!,
    });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error al borrar el comentario');
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



  Future<String> updateProfile({required String username,required String email,String? password} ) async {
    final token = await getToken();
    final body;
    if (token == null) {
      throw Exception('Usuario no logueado');
    }

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/x-www-form-urlencoded",
    };


    if(password != null && password.isNotEmpty){
      body = {
        'name': username,
        'email': email,
        'password':password,
      };
    } else {
      body = {
        'name': username,
        'email': email,
      };
    }

    final response = await http.put(
      Uri.parse('$baseUrl/update_profile'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Error al actualizar perfil');
    }
  }

  Future<String> reportPost(int id,String content) async{
    final token = await getToken();
    if(token == null){
      throw Exception('Usuario no logueado');
    }
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
      throw Exception('Error: No se pudo reportar');
    }
  }


  Future<bool> changeNSFW() async{
    final token = await getToken();
    if (token == null) {
      throw Exception('Usuario no logueado');
    }
    final headers = {
      "Authorization": "Bearer $token"};

    final response = await http.patch(
      Uri.parse('$baseUrl/change-nsfw/'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return response.body.toLowerCase() == 'true';
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Error al agregar actulizar');
    }
  }


  Future<bool> deleteAccount() async{
    final token = await getToken();
    if (token == null) {
      throw Exception('Usuario no logueado');
    }

    final headers = {
      "Authorization": "Bearer $token",
    };

    final response = await http.delete(
      Uri.parse('$baseUrl/user'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return true;
    } else{
      return false;
    }

  }



  Future<String> addComment(int id, String content) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Usuario no logueado');
    }

    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/x-www-form-urlencoded",
    };

    final body = {
      'content': content,
      'id_post': id.toString(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/comments'),
      headers: headers,
      body: body,
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print(response.statusCode);
      print(response.body);
      throw Exception('Error al agregar el comentario');
    }
  }



/*
  Future<String> addComment(int id,String content) async{
    final token = await getToken();
    if(token == null){
      throw Exception('Usuario no logueado');
    }
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "multipart/form-data",
    };
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/comments'));
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['content'] = content;
    request.fields['id_post'] = id.toString();

    final response = await request.send();
    if (response.statusCode == 200) {

      final responseData = await response.stream.bytesToString();

      return responseData;
    } else {
      print(response.statusCode);
      final responseData = await response.stream.bytesToString();
      final parsedResponse = json.decode(responseData);
      print(parsedResponse);
      return responseData;

    }
  }*/


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

