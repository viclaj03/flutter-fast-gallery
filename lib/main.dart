import 'dart:convert';

import 'package:fastgalery/screens/home.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/screens/posts_list.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // Configura esto según tus necesidades (puedes cambiarlo a false en producción)
  );


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
      ),
      themeMode: ThemeMode.system,
      home: /*FutureBuilder<String?>(
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
      ),*/HomeScreen(),
      initialRoute: '/',
      routes: {

        '/login': (context)=> const LoginScreen(),
        '/PostsListScreen': (context) => PostsListScreen(1),

      },
    );
  }

}