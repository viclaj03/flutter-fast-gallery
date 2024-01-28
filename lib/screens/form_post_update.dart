import 'dart:io';

import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/screens/posts_list.dart';
import 'package:fastgalery/services/api_services.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

ApiService apiService = new ApiService();
String titulo = '';
String descripcion = '';
bool nsfw = false;
String tags = '';








class FormUpadateScreen extends StatelessWidget  {
  final Post _post;
  final String old_rute;
  const FormUpadateScreen(this._post,this.old_rute,{Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      Scaffold(
        appBar: AppBar(
          title:  Text("actulizando: ${_post.title}"),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.black,
        ),
        body:  SingleChildScrollView(
          child: Formulario( _post,old_rute),
        ),
      );
  }
}

class Formulario extends StatefulWidget {
  final Post post;
  final String old_rute;
  const Formulario(this.post,this.old_rute,{Key? key}) : super(key: key);


  @override
  State<Formulario> createState() => _FormularioState(post,old_rute);
}

class _FormularioState extends State<Formulario> {
  final _formKey = GlobalKey<FormState>();

  _FormularioState(this.post,this.old_rute);
  final Post post;
  final String old_rute;



  @override
  Widget build(BuildContext context) {
    bool _isSaving = false;
    return Form(
        key: _formKey,

        child:
        Padding(
          padding: const EdgeInsets.all(20.0),
          child:

          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[


              Image.network(
                '${apiService.baseUrl}/static/images/${post.image_url}',
                //height: 280.0,
                //fit: BoxFit.cover,
              ),


              const Text(
                "Title:",
                style: TextStyle(fontSize: 18),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 16.0),
                child:
                TextFormField(
                  initialValue: post.title,
                  decoration:  InputDecoration(
                    hintText: 'Un titulo breve pero descriptivo',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    ),

                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El Titulo es obligatorio';
                    }
                    if (value.length < 5 || value.length >= 50) {
                      return 'debes contener menos de 50 cracteres y mas de 5, Actual: ${value.length} ';
                    }
                    titulo = value;
                    return null;
                  },
                ),
              ),
              const Text(
                "Description:",
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                decoration:  InputDecoration(
                  hintText: 'Breve descripcion del contenido del post',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),

                ),
                maxLines: 4,
                initialValue: post.description,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El contenido es obligatorio';
                  }

                  if (value.length >= 500) {
                    return 'debes contener menos de 500 characters ${value.length}';
                  }
                  //todo limitar el enumero de linea
                  int newlines = value.split('\n').length - 1;
                  if (newlines > 2) {
                    return 'maximo 2 saltos de lineas';
                  }
                  descripcion = value;
                  return null;
                },
              ),

              const Text(
                "Tags:",
                style: TextStyle(fontSize: 18),
              ),
              TextFormField(
                decoration:  InputDecoration(
                  hintText: 'tags descriptivos separados por comas',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)
                    )
                ),
                maxLines: 1,
                initialValue: post.tags,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El contenido es obligatorio';
                  }

                  if (value.length >= 500) {
                    return 'debes contener menos de 500 characters ${value.length}';
                  }
                  //todo limitar el enumero de linea
                  int newlines = value.split('\n').length - 1;
                  if (newlines > 1) {
                    return 'maximo 2 saltos de lineas';
                  }
                  tags = value;
                  return null;
                },
              ),


              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    "NSFW:",
                    style: TextStyle(fontSize: 18),
                  ),
                  Checkbox(
                    activeColor: Colors.red,
                    checkColor: Colors.black,
                    value: post.NSFW,
                    onChanged: (bool? value) {
                      setState(() {
                        post.NSFW = !post.NSFW;
                        nsfw = value!;
                      });
                    },
                  ),

                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,

                children: <Widget>[
                  ElevatedButton(
                    child: const Text('Rsert  Form'),
                    onPressed: () {
                      nsfw = false;
                      _formKey.currentState!.reset();


                      setState(() {

                      });
                    },
                  ),
                  ElevatedButton(
                    child: const Text('SAVE'),
                    onPressed: _isSaving?null :  () async {
                      if (_formKey.currentState!.validate()) {

                        setState(() {
                          _isSaving = true;
                        });
                        Map<String, dynamic> requestBody = {
                          'title': titulo,
                          'description': descripcion,
                          'NSFW': nsfw,
                          'tags':tags
                        };

                        setState(() {
                          _isSaving = false;
                        });
                        try{
                          Map<String, dynamic> response = await apiService.updatePost(requestBody,post.id);
                          print(response);
                          if(!response.isEmpty) {
                            //Navigator.push(context, MaterialPageRoute(
                            //    builder: (context) => ListImagesScreen()));
                            _formKey.currentState!.reset();

                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Imagen actulizada ${response['title']}'), backgroundColor: Colors.green));

                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => PostScreen(post)));
                          }
                        } catch (error) {
                          print(error);
                          // Muestra un mensaje de error si la autenticación falla
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al subir el post:$error'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        )
    );
  }
}


