import 'dart:convert';

import 'package:fastgalery/providers/shared_preferences.dart';
import 'package:fastgalery/screens/login.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/screens/posts_list.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';




ApiService apiService = ApiService();

Future<String?> usernameLogin() async{

  try{
    String userData = await apiService.getMyUser();
    await saveIdUser(json.decode(userData)['id']);
    await saveEmail(json.decode(userData)['email']);
    await saveUsername(json.decode(userData)['name']);
    return userData;
  }catch(e){
    return null;
  }

}



class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  FutureBuilder<String?>(
      future: usernameLogin(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Mientras espera, puedes mostrar un indicador de carga, por ejemplo.
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // Si hay un error, puedes manejarlo de acuerdo a tus necesidades.
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          // Dependiendo del resultado, muestra LoginScreen o PostsListScreen.
          final username = snapshot.data;
          return username != null ? PostsListScreen(json.decode(snapshot.data!)['id']) : LoginScreen();
        }
      },
    );
  }
}

