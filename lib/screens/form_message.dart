import 'package:dropdown_search/dropdown_search.dart';
import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/model/user.dart';
import 'package:fastgalery/providers/user_data.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:fastgalery/model/message.dart';


ApiService apiService = ApiService();


String _subjectInput = "";

String _bodyInput = "";

int _idUserInput = 0;


class MessageForm extends StatefulWidget {
  User? user;
  MessageForm({super.key,this.user});

  @override
  State<MessageForm> createState() => _MessageFormState(user);
}

class _MessageFormState extends State<MessageForm> {
  final _formKey = GlobalKey<FormState>();
  User? user;
  _MessageFormState(this.user);
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: GradientAppBar(title: "New Message",gradientColors:[
        Color(0xff611de1),
        Color(0xffa74bc0),
      ]),
      body: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[

                      _userSearch(user: user),
                      _subject(),
                      _body(),
                      _sendButton()
                    ]
                )
            )
        ),
      ),
    );
  }


  Widget _userSearch({User? user}){

    return
      Container(
          margin: EdgeInsets.only(bottom: 16.0),
          child: DropdownSearch<User>(
            selectedItem: user,
            popupProps: const PopupProps.menu(
              showSearchBox: true,
              isFilterOnline: true,
            ),
            asyncItems: (String filter) => apiService.getSearchUserList(filter),
            itemAsString: (User u) => u.name,
            onChanged: (User? data) => print(data),
            dropdownDecoratorProps:  DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                labelText: "Usuario",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  )
              ),

            ),
            validator: (value) {
              if (value == null) {
                return 'debes elegir el destinatario';
              } else {
                _idUserInput = value.id;
                return null;
              }
            },
          )
      );
  }

  Widget _subject(){
    return
      Container(
        margin: EdgeInsets.only(bottom: 16.0),
    child:TextFormField(
      initialValue: '',
      decoration:  InputDecoration(
        labelText: "Asunto del mansaje",
          hintText: 'Asunto del mensaje',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0)
          )

      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El asunto es obligatorio';
        }
        if (value.length >= 250) {
          return 'debes contener menos de 250 cracteres';
        }
        _subjectInput = value;
        return null;
      },
    )
      );
  }

  Widget _body(){
    return Container(
        margin: EdgeInsets.only(bottom: 16.0),
      child:TextFormField(
      decoration:  InputDecoration(
        labelText: "Contenido del mansaje",
          hintText: 'Contenido del mansaje',
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.0)
          )

      ),
      maxLines: 15,
      initialValue: '',
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'El contenido es obligatorio';
        }

        if (value.length >= 800) {
          return 'debes contener menos de 800 characters,actual: ${value.length}';
        }
        //todo limitar el enumero de linea
        int newlines = value.split('\n').length - 1;
        if (newlines > 10) {
          return 'maximo 10 saltos de lineas';
        }
        _bodyInput = value;
        return null;
      },
    )
    );
  }


  Widget _sendButton(){
    return Container(
      padding: EdgeInsets.all(8.0),
      child: ElevatedButton(
        child: const Text('ENVIAR'),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Llamada a la API para autenticar al usuario y obtener el token
            try {
              // Realiza la solicitud de inicio de sesión a la API y obtén el token


              if(!context.mounted) return;

              await apiService.sendMessage(_subjectInput, _bodyInput, _idUserInput);


              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('¡Enviado! '), backgroundColor: Colors.green,),
              );

              Navigator.pop(context);

              // Puedes navegar a otra pantalla o realizar acciones adicionales aquí
            } catch (error) {
              print(error);
              // Muestra un mensaje de error si el mensaje falla falla
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error al eviar Mensaje: $error'), backgroundColor: Colors.red,duration: Duration(seconds: 4)),
              );
            }
          }
        },
      ),
    );
  }




}






