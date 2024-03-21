import 'dart:convert';
import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/screens/forgot_password.dart';
import 'package:fastgalery/screens/post_show.dart';

import 'package:fastgalery/screens/posts_list.dart';
import 'package:fastgalery/screens/registre.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';



bool _invisiblePassword = true;


ApiService _apiService = ApiService();

String _emailInput = "";

String _password = "";



class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}





class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _invisiblePassword = true;
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: GradientAppBar(title: Text('FastGallery'),
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
                  _eMailInput(),
                  _passwordInput(),
                  _loginButton(),
                  const SizedBox(
                    height: 50,
                  ),
                  _registreButto(),
                  const SizedBox(
                    height: 20,
                  ),
                  _forgotPasswor()
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

          } else if(!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            //return 'invalid email';
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

          _password = value;
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
              String userData = await  _apiService.authenticateUser(_emailInput, _password);
              String username = json.decode(userData)['name'];
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

  Widget _forgotPasswor(){
    return TextButton(onPressed: (){
      Navigator.push(context, MaterialPageRoute(builder:  (context)=> ForgotPasswordScreen()));
    }, child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,

      children: const <Widget>[
        Icon(Icons.help),
        Text(' Forgot Password?')
      ],
    ));
  }









}


