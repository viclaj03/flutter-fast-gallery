import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/providers/shared_preferences.dart';
import 'package:fastgalery/screens/form_post_update.dart';
import 'package:fastgalery/screens/profile.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:full_screen_image/full_screen_image.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:like_button/like_button.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:readmore/readmore.dart';

import 'package:dio/dio.dart';

import 'package:path_provider/path_provider.dart';


final ApiService apiService = ApiService();




Future<Map<String, dynamic>> getIdUserAndPost(int id) async {
  final postJson = await apiService.getImage(id);
  final userId = await getIdUser();
  Post _post = Post.fromJsonString(postJson);
  return {'userId': userId, 'post': _post};
}


Future<void> reportPost(BuildContext context, int id)async{
  String content = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Reportar publicación'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Debes especificar el motivo de la denuncia";
              }
              content = value;
            },
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(Colors.red),
            ),
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save(); // Guarda el valor del campo de texto
                await apiService.reportPost(id, content);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post denunciado'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: Text('Reportar'),
          ),
        ],
      );
    },
  );
}


Future<void> downloadAndSaveImage(String imageUrl,String nameImage, BuildContext context) async {
  try {
    // Realiza la solicitud HTTP para obtener la imagen
    Response<Uint8List> response = await Dio().get<Uint8List>(
      imageUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    // Obtiene el directorio de documentos local para guardar la imagen
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/$nameImage.jpg';
    // Guarda la imagen localmente
    File file = File(filePath);
    await file.writeAsBytes(response.data!);

    // Guarda la imagen en la galería con una carpeta específica
    await ImageGallerySaver.saveImage(
        response.data!,
        name: nameImage,
        isReturnImagePathOfIOS: true
    );
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagen Descargada '), backgroundColor: Colors.green));
  } catch (error) {
    print('Error al descargar y guardar la imagen: $error');
  }
}


void downloadCallback(String id, DownloadTaskStatus status, int progress) {
  print(
      'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
  final SendPort send =
  IsolateNameServer.lookupPortByName('downloader_send_port')!;

  send.send([id, status, progress]);
}

//todo eleiminar post
Future<void> deletePost(BuildContext context,Post post) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Eliminar Pos'),
        content: Text('¿Estás seguro de realizar esta acción?\nno se puede deshacer'),
        actions: <Widget>[
          TextButton(
            onPressed: () {

              Navigator.of(context).pop();
              apiService.deleteImage(post.id);

              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/PostsListScreen');
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Imagen Eliminada '), backgroundColor: Colors.green));
            },
            child: Text('Si'),
          ),
          TextButton(
            onPressed: () {
              // Cerrar el cuadro de diálogo sin realizar la acción
              Navigator.of(context).pop();
              // Agrega aquí la lógica para la acción de cancelación

            },
            child: Text('No'),
          ),
        ],
      );
    },
  );
}



class PostScreen extends StatelessWidget {
  final Post _post;
  const PostScreen(this._post, {Key? key})
      :super(key: key);
  @override
  Widget build(BuildContext context) {
    //_init();
    return
      Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: const IconThemeData(
              color: Colors.black,
              size: 28.0,
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0), // Ajusta el espaciado del icono
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.withOpacity(0.5), // Color gris transparente
                ),
                child: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context,'backform');
                  },
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: Colors.transparent, // Establece el color de fondo de la AppBar como transparente
            elevation: 0,
          ),
          body:

          FutureBuilder(
            future:   getIdUserAndPost(_post.id),//apiService.getImage(_post.id),
            builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>>snapshot) {
              if (snapshot.hasData) {
                final userId = snapshot.data!['userId'];
                final Post _post = snapshot.data!['post'];
                return _imageContent(_post,userId);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          )
        // _imageContent(_post),
      );
  }
}



Widget _imageContent(Post _post, userId){
  return SingleChildScrollView(child:Column(
    mainAxisAlignment: MainAxisAlignment.start, // Esto alinea los widgets en la parte superior
    crossAxisAlignment: CrossAxisAlignment.center,
    children:  [
      ImageShow(post: _post),
      Text(_post.title,style: TextStyle(fontSize: 25),),
      ActionBar(post: _post,userId:userId),
      ReadMoreText(
        _post.description,
        style: TextStyle(color: Colors.black),
        colorClickableText: Colors.pink,
        trimMode: TrimMode.Line,
        trimLines: 1,
        trimCollapsedText: '..leer mas',
        trimExpandedText: '.. ocultar',
      ),
      Wrap(
        spacing: 8.0, // Espaciado entre las etiquetas
        runSpacing: 8.0, // Espaciado entre las filas de etiquetas
        children: _post.tags.split(',')
            .map((tag) => Chip(
          label: Text(tag),
          backgroundColor: Colors.blue,
          labelStyle: TextStyle(color: Colors.white),
        )).toList(),
      ),
    ],
  ));
}






class ImageShow extends StatefulWidget {
  final Post post;
  const ImageShow({required this.post, Key? key}) : super(key: key);

  @override
  State<ImageShow> createState() => _ImageShowState(post);
}

class _ImageShowState extends State<ImageShow> {
  Post post;

  _ImageShowState(this.post);

  @override
  Widget build(BuildContext context) {
    return Hero(tag: 'imageHero${post.id}', child:
    FullScreenWidget(


        disposeLevel: DisposeLevel.High,    child:
        InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(20.0),
            //minScale: 0.1,
            //maxScale: 1.6,
            child:
    Image.network('${apiService.baseUrl}/static/images/${post.image_url}',
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {

            return Center(child: child);
          } else {
            return Image.network('${apiService.baseUrl}/static/images_render/${post
                .image_url_ligere}');
          }
        }))
    )

    );
  }
}




class ActionBar extends StatelessWidget {
  final Post post;
  final int userId;
  const ActionBar({super.key, required this.post, required this.userId});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
            onTap: () {
              // Navegar a ProfileScreen
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(id_user: post.user.id)));
            },

          child: Text('${post.user.name}',style: TextStyle(fontSize: 20)),
        ),

        Row(
          children: <Widget>[

            post.user.id == userId || true?

            PopupMenuButton<String>(
                onSelected: (value) {
                  // Manejar la selección del menú
                  if (value == 'Share') {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('compartir '), backgroundColor: Colors.green));
                  } else if (value == 'Delete') {
                    deletePost(context,post);
                  } else if (value == 'Edit'){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FormUpadateScreen(post,'/PostsListScreen')));
                  }else if (value == 'Dowload'){
                    downloadAndSaveImage('${apiService.baseUrl}/static/images/${post.image_url}',post.image_url,context);
                  }else if (value == 'Report'){
                    reportPost(context,post.id);
                  }
                },
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                        value: 'Share',
                        child:Row(
                          children: const <Widget>[
                            Icon(Icons.share),
                            Text('Compartir')
                          ],
                        )
                    ),
                    if(post.user.id == userId)
                    PopupMenuItem<String>(
                        value: 'Delete',
                        child: Row(
                          children: const <Widget>[
                            Icon(Icons.delete,color: Colors.red),
                            Text('Eliminar')
                          ],
                        )
                    ),
                    if(post.user.id == userId)
                    PopupMenuItem<String>(
                        value: 'Edit',
                        child: Row(
                          children: const <Widget>[
                            Icon(Icons.edit,color: Colors.green) ,
                            Text('Editar')
                          ],
                        )
                    ),
                    PopupMenuItem<String>(
                        value: 'Dowload',
                        child: Row(
                          children: const <Widget>[
                            Icon(Icons.download,color: Colors.blue) ,
                            Text('Descargar')
                          ],
                        )
                    ),
                    PopupMenuItem<String>(
                        value: 'Report',
                        child: Row(
                          children: const <Widget>[
                            Icon(Icons.report,color: Colors.red) ,
                            Text('Reportara',style: TextStyle(color: Colors.red),)
                          ],
                        )
                    ),

                  ];
                }):IconButton(
              onPressed: (){},
              icon: Icon(Icons.share) ,
              color: Colors.grey,),
            LikeButton(
              isLiked: post.favorited_by_user,
              onTap: ((isLiked) => ApiService().likePost(post)),
            ),

          ],
        )
      ],
    );
  }
}







