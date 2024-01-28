import 'dart:convert';
import 'package:fastgalery/screens/post_show.dart';

import 'package:fastgalery/screens/posts_list.dart';
import 'package:fastgalery/screens/registre.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastgalery/providers/shared_preferences.dart';


ApiService apiService = ApiService();

String emailInput = "";

String passwordInput = "";



class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}





class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('FastGallery')),
      body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
              ClipRRect(
              borderRadius: BorderRadius.circular(10000002),
                  child:
                  Image.asset('assets/icon/1024.png',scale: 5),
              ),
                  const SizedBox(
                    height: 50,
                  ),
                  _eMailInput(),
                  _passwordInput(),
                  _loginButton(),
                  const SizedBox(
                    height: 100,
                  ),
                  _registreButto(),
                ],
              ),
            ),
          )
      ),
    );
  }


  Widget _eMailInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'User or Email',
            hintText: '',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
            )
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return'Sorry, user cant \'t be empty';
            //todo ejercicio3 verificamos que es un email valido
          } else if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            //return 'invalid email';
          }
          emailInput = value;
          return null;
        },
      ),
    );
  }
  Widget _passwordInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: invisiblePassword,
        obscuringCharacter: '*',
        decoration: InputDecoration(
          hintText: 'Write your password',
          labelText: 'Password',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0)
          ),
          suffixIcon: IconButton(
            icon: invisiblePassword? const Icon(Icons.visibility_off, color: Colors.black,):const Icon(Icons.visibility, color: Colors.black,),
            onPressed: () {
              setState(() {
                invisiblePassword = !invisiblePassword;
              });
            },
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Sorry, password can not be empty';
          }
//todo Ejercicio 3 verificamos que tine minimo  una mayuscula, numero y simbolo ademas del tamaño
          if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(value)) {
            //return null;// 'Enter valid password';
          }
          passwordInput = value;
          return null;
        },
      ),
    );
  }

// Reemplaza la lógica del botón de inicio de sesión con la llamada a la API
  Widget _loginButton(){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: const Text('Login'),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Llamada a la API para autenticar al usuario y obtener el token
            try {
              // Realiza la solicitud de inicio de sesión a la API y obtén el token
              String userData = await authenticateUser(emailInput, passwordInput);
              username = json.decode(userData)['name'];
              int id_user = json.decode(userData)['id'];
              if(!context.mounted) return;
              /*Navigator.pushNamedAndRemoveUntil(context, '/PostsListScreen',
                    (route) => false,arguments: {id_user: id_user} );*/
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>PostsListScreen(id_user)),(route) => false);
              // Muestra un mensaje de bienvenida con el token
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Bienvenido!  $username'), backgroundColor: Colors.green,),
              );

              // Puedes navegar a otra pantalla o realizar acciones adicionales aquí
            } catch (error) {
              print(error);
              // Muestra un mensaje de error si la autenticación falla
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error de inicio de sesión: $error'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }


  Widget _registreButto(){
    return Container(


        child: ElevatedButton(
          child: const Text('Registre'),
          onPressed:(){
            Navigator.push(context, MaterialPageRoute(builder: (context) => RegistreScreen()));
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        )
    );
  }







  Future<String> authenticateUser(String email, String password) async {

    final response = await http.post(
        Uri.parse('http://192.168.1.148:8000/login'),
        body:{

          'username': emailInput,
          'password': passwordInput,
        }
    );

    if (response.statusCode == 200) {
      final token =  json.decode(response.body);
      await saveToken(token['access_token']);



      String userData = await apiService.getMyUser();
      await saveIdUser(json.decode(userData)['id']);
      await saveEmail(json.decode(userData)['email']);
      await saveUsername(json.decode(userData)['name']);
      print(response.body);
      return userData;
    } else {
      print(response.body);
      // Si la solicitud falla, lanza una excepción
      throw Exception('Error de autentificación T.T');
    }
  }

}


