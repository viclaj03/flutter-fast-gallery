import 'dart:convert';
import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/screens/post_show.dart';

import 'package:fastgalery/screens/posts_list.dart';
import 'package:fastgalery/screens/terms_and_conditions.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fastgalery/providers/shared_preferences.dart';
import 'package:fastgalery/extesionFunctions/extension_function.dart';


String _username = "";

String _emailInput = "";

String _password = "";

bool _invisiblePassword = true;

bool _isChecked = false;

ApiService _apiService = ApiService();

class RegistreScreen extends StatefulWidget {
  const RegistreScreen({Key? key}) : super(key: key);

  @override
  State<RegistreScreen> createState() => _RegistreScreenState();
}





class _RegistreScreenState extends State<RegistreScreen> {
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _invisiblePassword = true;
  }

  @override
  Widget build(BuildContext context) {

    return  Scaffold(
        appBar: GradientAppBar(title: const Text('Registre'),
        gradientColors: const [
          Color(0xff611de1),
          Color(0xffa74bc0),
          ],
        ),
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
                _acceptTermsAndConditions(),
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
          _username = value;
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
          _emailInput = value;
          return null;
        },
      ),

    );
  }
  Widget _passwordInput(){

    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: _invisiblePassword,
        obscuringCharacter: '*',
        decoration: InputDecoration(
            hintText: 'Write your password',
            labelText: 'Password',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
            ),
          suffixIcon: IconButton(
            icon: _invisiblePassword? const Icon(Icons.visibility_off, color: Colors.black,):const Icon(Icons.visibility, color: Colors.black,),
            onPressed: () {
              setState(() {
                _invisiblePassword = !_invisiblePassword;
              });
            },
          ),
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Sorry, password can not be empty';
          }
          if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$').hasMatch(value)) {
            return  'invalid password [8 digitos, mayusculas y minusculas \ny numeros]';
          }
          _password = value;
          return null;
        },
      ),
    );
  }

  Widget _acceptTermsAndConditions(){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      verticalDirection: VerticalDirection.up,
      children: <Widget>[
        Checkbox(
            value: _isChecked,
            onChanged: (value){
              setState(() {
                _isChecked = value!;
              });
            }),
        TextButton(
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TermsAndConditiosnScreen()),
              );
            },
            child: Text('Aceptar terminos y condiciones'))
      ],
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

            if(_isChecked) {
              // Llamada a la API para autenticar al usuario y obtener el token
              try {
                // Realiza la solicitud de inicio de sesión a la API y obtén el token
                int id = await _apiService.resgistreUser(email: _emailInput,
                    username: _username,
                    password: _password);

                if (!context.mounted) return;


                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (context) => PostsListScreen(id)), (
                    route) => false);
                //Navigator.push(context, MaterialPageRoute(builder: (context)=>PostScreen()));
                // Muestra un mensaje de bienvenida con el token
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('¡Bienvenido! '),
                    backgroundColor: Colors.green,),
                );

                // Puedes navegar a otra pantalla o realizar acciones adicionales aquí
              } on Exception catch (error) {
                print(error);
                // Muestra un mensaje de error si la autenticación falla
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Error de Registro: ${error.getMessage}'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 4)),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('Debe aceptar los terminos y condiciones'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4)),
              );
            }
          }
        },
      ),
    );
  }









}


