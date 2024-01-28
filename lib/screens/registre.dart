import 'dart:convert';
import 'package:fastgalery/screens/post_show.dart';

import 'package:fastgalery/screens/posts_list.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastgalery/providers/shared_preferences.dart';


String username = "";

String emailInput = "";

String passwordInput = "";

bool invisiblePassword = true;



class RegistreScreen extends StatefulWidget {
  const RegistreScreen({Key? key}) : super(key: key);

  @override
  State<RegistreScreen> createState() => _RegistreScreenState();
}





class _RegistreScreenState extends State<RegistreScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        appBar: AppBar(title: const Text('Registre')),
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
                _usernamInput(),
                _eMailInput(),
                _passwordInput(),
                _registreButton()
              ],
            ),
          ),
        ),
        ),
      );
  }


  Widget _usernamInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'User Name',
            hintText: 'Whrite your User name',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
            )
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return'Sorry, user cant \'t be empty';
            //todo ejercicio3 verificamos que es un email valido
          } else if(value.length < 3 && value.length > 255) {
            return 'El username debe tene min 4  max 254';
          }
          username = value;
          return null;
        },
      ),

    );
  }





  Widget _eMailInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Whrite your email address',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
            )
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return'Sorry, email cant \'t be empty';

          } else if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            return 'invalid email';
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
          if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$').hasMatch(value)) {
            return  'inValid password [8 digitos, mayusculas y minusculas \ny numeros]';
          }
          passwordInput = value;
          return null;
        },
      ),
    );
  }

// Reemplaza la lógica del botón de inicio de sesión con la llamada a la API
  Widget _registreButton(){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: const Text('Registre'),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Llamada a la API para autenticar al usuario y obtener el token
            try {
              // Realiza la solicitud de inicio de sesión a la API y obtén el token
              int id = await resgistreUser(emailInput, passwordInput);

              if(!context.mounted) return;



              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>PostsListScreen(id)),(route) => false);
              //Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreen()));
              // Muestra un mensaje de bienvenida con el token
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Bienvenido! '), backgroundColor: Colors.green,),
              );

              // Puedes navegar a otra pantalla o realizar acciones adicionales aquí
            } catch (error) {
              print(error);
              // Muestra un mensaje de error si la autenticación falla
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error de inicio de sesión: $error'), backgroundColor: Colors.red,duration: Duration(seconds: 4)),
              );
            }
          }
        },
      ),
    );
  }







  Future<int> resgistreUser(String email, String password) async {

    final response = await http.post(
        Uri.parse('http://192.168.1.148:8000/registre'),

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

}


