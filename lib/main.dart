import 'dart:convert';

import 'package:fastgalery/screens/posts_list.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'screens/login.dart';

ApiService apiService = ApiService();

Future<String?> usernameLogin() async{

  try{
    String userData = await apiService.getMyUser();
    print(json.decode(userData));
    return json.decode(userData)['name'];
  }catch(e){
    return null;
  }

}


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const _title = 'Fast Galery';

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      theme:  ThemeData(
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.system,
      home: FutureBuilder<String?>(
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
            return username != null ? PostsListScreen() : LoginScreen();
          }
        },
      ),
      routes: {
        'login': (context)=> const LoginScreen(),
        'PostsListScreen': (context) => PostsListScreen(),
      },
    );
  }

}