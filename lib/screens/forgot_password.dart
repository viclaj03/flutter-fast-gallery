import 'dart:convert';
import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/screens/new_password.dart';
import 'package:fastgalery/screens/post_show.dart';

import 'package:fastgalery/screens/posts_list.dart';
import 'package:fastgalery/screens/registre.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';


ApiService _apiService = ApiService();

String _emailInput = "";


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: GradientAppBar(title: 'Forgot Password',gradientColors: [
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
                      _textMessage(),
                      const SizedBox(
                        height: 50,
                      ),
                      _eMailInput(),
                      _sendButton()
                    ],
                  )
              ),
            )
        )
    );
  }


  Widget _textMessage(){
    return Text('Se te enviara un correo con una codigo numerico',style: TextStyle(fontSize: 15),);
  }

  Widget _eMailInput(){
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@example.es',
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


  Widget _sendButton(){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: const Text('Send'),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {

            try {
              // Realiza la solicitud de inicio de sesión a la API y obtiene el token
              String response = await  _apiService.forgotPassword(email: _emailInput);

              if(!context.mounted) return;


              Navigator.push(context, MaterialPageRoute(builder: (context) =>  NewPasswordScreen(email: _emailInput)));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${response}'), backgroundColor: Colors.green,),
              );


            } catch (error) {
              print(error);
              // Muestra un mensaje de error si la autenticación falla
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${error}'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }















}
