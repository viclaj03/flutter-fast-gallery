
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'dart:ui';

import 'package:fastgalery/model/comment.dart';
import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/providers/comment_data.dart';
import 'package:fastgalery/providers/post_data.dart';
import 'package:fastgalery/providers/shared_preferences.dart';
import 'package:fastgalery/screens/form_post_update.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/screens/post_show_copia_07_02.dart';
import 'package:fastgalery/screens/profile.dart';

import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:full_screen_image/full_screen_image.dart';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:like_button/like_button.dart';

import 'package:readmore/readmore.dart';

import 'package:dio/dio.dart';

import 'package:path_provider/path_provider.dart';



import 'package:flutter/services.dart';



int _currentPage = 1;

int _currentPageComment = 1;


final ApiService _apiService = ApiService();

final TextEditingController commentController = TextEditingController();






Future<Map<String, dynamic>> getIdUserAndPost(int id) async {

  final postJson = await _apiService.getPost(id);
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
                await _apiService.reportPost(id, content);
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

Future<Comment> addComment(BuildContext context, int id,String comment)async{
  var respuesta = await _apiService.addComment(id, comment);
  print(respuesta);

  return Comment.fromJsonString(respuesta);
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
Future<void> deletePost(BuildContext context,Post post, ) async {
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
              _apiService.deleteImage(post.id);

              Navigator.pop(context,post.id);
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Imagen Eliminada '), backgroundColor: Colors.green));
            },
            child: Text('Si'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('No'),
          ),
        ],
      );
    },
  );
}




class PostScreen extends StatefulWidget {
  final Post _post;
  const PostScreen(this._post,{super.key});

  @override
  State<PostScreen> createState() => _PostScreenState(_post);
}

class _PostScreenState extends State<PostScreen> {
  final Post _post;
  final ScrollController _scrollController = ScrollController();
  final PostData _postData = PostData.fromJson('[]');
  _PostScreenState(this._post);


  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    _currentPageComment = 1;
    _loadData();
    _scrollController.addListener(_scrollListener);
    //_searchController.addListener(_onSearchChanged);
  }


  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }



  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent ) {
      // Llegaste al final de la lista, carga más datos
      _loadData();
    }
  }

  Future<void> _loadData() async {

    try {
      print('pagina actual -> $_currentPage');
      final jsonData = await _apiService.getImageListSearch(_currentPage,'${_post.tags},${_post.user.name}');
      final newData = PostData.fromJson(jsonData);
      if (newData.getSize() > 0) {
        setState(() {
          PostData.addMoreData(_postData, newData);
          //todo para evitar que aparezca el mismo post
          _postData.deletePostById(_post.id);
          _currentPage++;
        });
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }

  }


  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
      body: FutureBuilder(
        future:   getIdUserAndPost(_post.id),//apiService.getImage(_post.id),
        builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>>snapshot) {
          if (snapshot.hasData) {
            final userId = snapshot.data!['userId'];
            final Post _post = snapshot.data!['post'];
            return
              CustomScrollView(
                  controller: _scrollController ,
                  slivers :[
                    SliverToBoxAdapter(child: _imageContent(_post,userId,context)),
                    _ImageList(scrollController: _scrollController, postData: _postData)
                  ]);
            //;
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }



}




Widget _imageContent(Post _post, userId, BuildContext context){

  return  Column(
    mainAxisAlignment: MainAxisAlignment.start, // Esto alinea los widgets en la parte superior
    crossAxisAlignment: CrossAxisAlignment.center,
    children:  [
      ImageShow(post: _post),
      Text(_post.title,style: TextStyle(fontSize: 25),),
      Padding(padding: const EdgeInsets.all(20.0),child: Column(
        children: [
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
        ],
      )),

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
      Divider(color: Colors.black,thickness: 0.8,indent: 20,endIndent: 20,),
      ElevatedButton(child: const Text('Show Comments'),
        style:  ElevatedButton.styleFrom(backgroundColor: Colors.red,shape: StadiumBorder()),
        onPressed: (){
          showModalBottomSheet(context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (BuildContext context) {

                return Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical( top:  Radius.circular(20), )
                    //border: Border.all()
                  ),
                  height: 450,
                  //color: Colors.white,
                  child: CommentList( postId: _post.id,userId:  userId),
                );
              }
          );
        },
      ),
    ],
  );
}





class CommentList extends StatefulWidget {

  final postId;
  final userId;
  const CommentList({super.key, this.postId,this.userId});

  @override
  State<CommentList> createState() => _CommentListState(postId,userId);
}

class _CommentListState extends State<CommentList> {
  final ScrollController _scrollController = ScrollController();
  final CommentData _commentData = CommentData.fromJson('[]');



  bool isKeyboardVisible = false;
  final postId;
  final userId;
  _CommentListState(this.postId,this.userId);



  void _loadComments(CommentData commentData,int postId) async {
    try {

      final jsonData = await _apiService.getComments(postId, _currentPageComment);

      if(!jsonData.isEmpty) {
        final newData = CommentData.fromJson(jsonData);
        setState(() {
          commentData.addData(newData.getComments());
        });
        _currentPageComment++;
      }

    } catch (e) {
      print('Error al cargar comentarios: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPageComment = 1;
    if(mounted) {
      _loadComments(_commentData, postId);
      _scrollController.addListener(_scrollListener);


  }

    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          isKeyboardVisible = visible;
        });
      }
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent ) {
      // Llegaste al final de la lista, carga más datos

      _loadComments(_commentData, postId);
    }
  }


  @override
  Widget build(BuildContext context) {
    final FocusNode commentFocus = FocusNode();


    void showOptionsComment(BuildContext context, int commentIndex, CommentData commentData, bool isOwner,) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Text('Copiar comentario al portapapeles'),
                    onTap: () {
                      Clipboard.setData(ClipboardData(text:_commentData.getComment(commentIndex).content));

                      Navigator.pop(context);
                    },
                  ),
                  if(isOwner)
                    ListTile(
                      title: Text('Eliminar',style: TextStyle(color: Colors.red)),
                      onTap: () async {

                        try{
                          await _apiService.deleteComment(_commentData.getComment(commentIndex).id);
                          setState(() {
                            _commentData.deleteCommentById(_commentData.getComment(commentIndex).id);
                          });
                        }catch(e){
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$e'), backgroundColor: Colors.red),
                          );
                        }

                        Navigator.pop(context);
                      },
                    ),
                  // Agrega más opciones si es necesario
                ],
              ),
            ),
          );
        },
      );
    }

    return
      Column(
        children: [
          const Padding(
              padding: const EdgeInsets.only(top: 15),
              child:  Text('COMENTARIOS')),

          Visibility(
            visible: !isKeyboardVisible,
            child:
            Expanded(
                child:ListView.builder(
                  controller: _scrollController,
                  itemCount: _commentData.getSize(),
                  itemBuilder: (BuildContext context,int index){

                    return
                      GestureDetector(
                        onLongPress: () {
                          print('se presiono');
                          showOptionsComment(context, index,_commentData,userId ==_commentData.getComment(index).user.id); // Pasa el índice del comentario a la función showModal
                        },
                        child: ListTile(
                          title: Text('${_commentData.getComment(index).user.name} ${userId ==_commentData.getComment(index).user.id?"(tu)":"" }'),
                          subtitle: Text(_commentData.getComment(index).content,style: TextStyle(fontSize: 18,color: Colors.black)),
                          leading: const Icon(Icons.account_circle),
                          trailing: Text(  '${DateFormat('dd-MM-yy').format(_commentData.getComment(index).created_at).toString()} '),
                        ),
                      );
                  },
                )
            ),),

          Divider(thickness: 1.5,color: Colors.black,),
          Padding(
              padding: const EdgeInsets.only(left: 15),
              child:
              TextField(
                controller: commentController,

                decoration: InputDecoration(
                  hintText: 'new Comment',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0)
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send,color: Colors.red,),
                    onPressed: () async {
                      String newComment = commentController.text;
                      if ( newComment != null && newComment.isNotEmpty ){
                        print('--> $newComment');
                        try{
                          Comment comment = await addComment(context, postId, newComment);
                          FocusScope.of(context).unfocus();
                          _commentData.addComment(comment);
                          commentController.text = "";
                        }catch(e){
                          print(e);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('$e'), backgroundColor: Colors.blueAccent));
                        }
                      } else {
                        print("es null???");
                      }
                      //aqui me gustaria coger el value del form y pasarlo auna funcion
                    },
                  ),
                ),
              )
          )
        ],
      )
    ;
  }
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

    //minScale: 0.1,
    //maxScale: 1.6,

    Image.network('${_apiService.baseUrl}/static/images/${post.image_url}',
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {

            return Center(child: child);
          } else {
            return Image.network('${_apiService.baseUrl}/static/images_render/${post
                .image_url_ligere}');
          }
        })
    )

    );
  }
}




class ActionBar extends StatelessWidget {
  final Post post;
  final int userId;

  const ActionBar({super.key,required this.post, required this.userId});

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

          child:
          Row(
            children: [
              Icon(Icons.account_circle),
              Text(' ${post.user.name}',style: TextStyle(fontSize: 20)),
            ],
          ),

        ),
        Row(
          children: <Widget>[

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
                    downloadAndSaveImage('${_apiService.baseUrl}/static/images/${post.image_url}',post.image_url,context);
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
                            Text('Reportar',style: TextStyle(color: Colors.red),)
                          ],
                        )
                    ),

                  ];
                }),
            LikeButton(
              isLiked: post.favorited_by_user,
              onTap: ((isLiked) => _apiService.likePost(post)),
            ),

          ],
        )
      ],
    );
  }
}


///////


class _ImageList extends StatefulWidget {
  final ScrollController scrollController;

  final PostData postData;
  const _ImageList({
    Key? key,
    required this.scrollController,

    required this.postData,

  }) : super(key: key);

  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<_ImageList> {
  @override
  Widget build(BuildContext context) {
    return  SliverGrid(

      gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: calculateCrossAxisCount(context),
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          final post = widget.postData.getPost(index);
          return PostView(post);
        },
        childCount: widget.postData.getSize(),
      ),
    );
  }
  Widget PostView(Post post){
    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            //textDirection: TextDirection.rtl,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: !post.NSFW?ImageFiltered(
                      imageFilter: post.NSFW? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0):ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child:Image.network(
                        '${_apiService.baseUrl}/static/images_render/${post.image_url_ligere}',)):
                  ColorFiltered(
                      colorFilter: ColorFilter.mode(Color(0xABD7322F), BlendMode.lighten),
                      child:
                      ImageFiltered(
                          imageFilter: post.NSFW? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0):ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child:Image.network(
                            '${_apiService.baseUrl}/static/images_render/${post.image_url_ligere}',)

                      )
                  ),
                ),
              ),
              Text(post.title),
            ],
          )
        ],
      ),
      onTap: () {

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PostScreen(post)),
        ).then((result) =>
        {
          if(result != null && result is int){
            setState(() {
              widget.postData.deletePostById(result);
            })

          }
        });
      },
    );
  }
}






