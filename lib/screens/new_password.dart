import 'dart:convert';
import 'package:fastgalery/customWidgest/grandient_app_bar.dart';


import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';


ApiService _apiService = ApiService();

String _email= "";

String _code = "";

String _password= "";

String _passwordRepeat = "";

bool _invisiblePassword = true;

class NewPasswordScreen extends StatefulWidget {
  final String email;
  const NewPasswordScreen(  {required this.email, super.key});
  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState(email:  email);
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final email;
  _NewPasswordScreenState({required String this.email});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _email = email;
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: GradientAppBar(title: Text('New Password'),
            gradientColors: const [
              Color(0xff611de1),
              Color(0xffa74bc0),
            ]),

        body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10000002),
                        child:
                        Image.asset('assets/icon/1024.png',scale: 5),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      _textMessage(email),
                      const SizedBox(
                        height: 50,
                      ),
                      _codeInput(),
                      _passwordInput(),
                      _passwordInputRepeat(),

                      _sendButton()
                    ],
                  )
              ),
            )
        )
    );
  }

  Widget _textMessage(email){
    return Text('Introduzca el Codigo que le hemos enviado a:\n $email',style: TextStyle(fontSize: 15),);
  }

  Widget _codeInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'Code',
            hintText: '000000',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
            )
        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return'Sorry, email cant \'t be empty';

          } else if(value.length != 6) {
            return 'el codigo tiene 6 digitos';
          }
          _code = value;
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



  Widget _passwordInputRepeat(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: true,
        obscuringCharacter: '*',
        decoration: InputDecoration(
          hintText: 'Write your password again',
          labelText: 'Reapeat Password',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0)
          ),

        ),
        validator: (value){
          if(value == null || value.isEmpty){
            return 'Sorry, password can not be empty';
          }
          if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$').hasMatch(value)) {
            return  'invalid password [8 digitos, mayusculas y minusculas \ny numeros]';
          }

          if(value != _password){
            return 'Passwords do not match';
          }


          return null;
        },
      ),
    );
  }




  Widget _sendButton(){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: const Text('Send'),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Llamada a la API para autenticar al usuario y obtener el token
            try {
              // Realiza la solicitud de inicio de sesión a la API y obtén el token
              String response = await  _apiService.newPassword(email: _email,code: _code,password: _password);

              if(!context.mounted) return;
              /*Navigator.pushNamedAndRemoveUntil(context, '/PostsListScreen',
                    (route) => false,arguments: {id_user: id_user} );*/
              Navigator.pop(context);
              Navigator.pop(context);
              // Muestra un mensaje de bienvenida con el token
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contraseña cambiada con exito'), backgroundColor: Colors.green,),
              );

              // Puedes navegar a otra pantalla o realizar acciones adicionales aquí
            } catch (error) {
              print(error);
              // Muestra un mensaje de error si la autenticación falla
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$error'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }

}
