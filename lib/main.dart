import 'dart:convert';

import 'package:fastgalery/screens/home.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/screens/posts_list.dart';
import 'package:fastgalery/screens/profile.dart';
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
  //windows 10 falla por esto
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: false // Configura esto según tus necesidades (puedes cambiarlo a false en producción)
  );


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static const _title = 'FastGallery';

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: _title,
      theme:  ThemeData(
        brightness: Brightness.light
      ),
      darkTheme: ThemeData(
        brightness: Brightness.light,
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(),
      initialRoute: '/',
      routes: {
        '/login': (context)=> const LoginScreen(),
      },
    );
  }

}