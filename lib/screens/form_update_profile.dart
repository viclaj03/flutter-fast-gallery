import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/main.dart';
import 'package:fastgalery/model/user.dart';
import 'package:fastgalery/screens/form_post.dart';
import 'package:flutter/material.dart';


String username = "";

String emailInput = "";

String passwordInput = "";

bool invisiblePassword = true;



class FormUpdatePorfileScreen extends StatelessWidget {
  final User user;
  const FormUpdatePorfileScreen({super.key,required  this.user});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: GradientAppBar(
        title: "Editando  ${user.name}  ",
        gradientColors: const <Color>[
          Color(0xff611de1),
          Color(0xffa74bc0),
        ],
      ),
      body: SingleChildScrollView(
        child: Formulario( user),
      ) ,
    );
  }
}


class Formulario extends StatefulWidget {
  final User _user;
  const Formulario( this._user, {super.key});

  @override
  State<Formulario> createState() => _FormularioState(_user);
}

class _FormularioState extends State<Formulario> {
  final _formKey = GlobalKey<FormState>();
  User user;

  _FormularioState(this.user);


  @override
  Widget build(BuildContext context) {
    return Form(
        child: Column(
          children: <Widget>[
            const Icon(Icons.account_circle, size: 120),
            Text('Editando Perfil de usuario'.toUpperCase()),
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _usernamInput(user),
                    _eMailInput(user),
                    const Divider(color: Colors.black,
                      thickness: 1,
                      indent: 0,
                      endIndent: 0,),
                    const Text("Dejar en blanco para no cambiar"),
                    _passwordInput(),
                    _submitBootom(context)

                  ],
                ),
              ),
            ),
          ],
        )
    );
  }


  Widget _usernamInput(User user) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: user.name,
        decoration: InputDecoration(
            labelText: 'User name',
            hintText: 'Whrite your User name',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
            )
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Sorry, user cant \'t be empty';
          } else if (value.length < 3 && value.length > 255) {
            return 'El username debe tene min 4  max 254';
          }
          username = value;
          return null;
        },
      ),

    );
  }


  Widget _eMailInput(User user) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: user.email,
        decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'Whrite your email address',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0)
            )
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Sorry, email cant \'t be empty';
          } else if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(value)) {
            return 'invalid email';
          }
          emailInput = value;
          return null;
        },
      ),

    );
  }

  Widget _passwordInput() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: invisiblePassword,
        obscuringCharacter: '*',
        decoration: InputDecoration(
          hintText: 'Write your password',
          labelText: 'New Password',
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            value = null;
            return null;
          }
          if (!RegExp(
              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$')
              .hasMatch(value)) {
            return 'Enter valid password';
          }
          passwordInput = value;
          return null;
        },
      ),
    );
  }




  Widget _submitBootom(BuildContext context){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
        child: const Text('Actualizar'),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {

            try{
              await apiService.updateProfile(username: username, email: emailInput,password: passwordInput);

              user.email = emailInput;
              user.name = username;
              _formKey.currentState!.reset();
              passwordInput = "";
              Navigator.pop(context,user);
            }catch(e){
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al actulizar:$e'), backgroundColor: Colors.red),
              );
            }
          }
        },
      ),
    );
  }
}