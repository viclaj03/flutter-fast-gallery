import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/providers/post_data.dart';
import 'package:fastgalery/screens/form_post.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:readmore/readmore.dart';

final ApiService apiService = ApiService();


class PostScreen extends StatelessWidget {
  final Post _post;
  const PostScreen(this._post, {Key? key})
   :super(key: key);
  @override
  Widget build(BuildContext context) {
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
                Navigator.pop(context);
              },
              color: Colors.white,
            ),
          ),
        ),



        backgroundColor: Colors.transparent, // Establece el color de fondo de la AppBar como transparente
        elevation: 0,

      ),
      body:SingleChildScrollView(child:Column(
        mainAxisAlignment: MainAxisAlignment.start, // Esto alinea los widgets en la parte superior
        crossAxisAlignment: CrossAxisAlignment.center,
        children:  [
          ImageShow(post: _post),
          Text(_post.title,style: TextStyle(fontSize: 25),),
          ActionBar(post: _post),
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
      )
      ),
    );
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
    return Hero(tag: 'imageHero${post.id}', child: Image.network('${apiService.baseUrl}/static/images/${post.image_url}'));

  }
}




class ActionBar extends StatelessWidget {
  final Post post;
  const ActionBar({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(post.user.name,style: TextStyle(fontSize: 20)),
        Row(
          children: <Widget>[
            IconButton(
              onPressed: (){print('object');},
              icon: Icon(Icons.share) ,
              color: Colors.grey,),
            IconButton(
              onPressed: (){print('object');},
              icon: Icon(Icons.heart_broken) ,
              color: Colors.grey,),
            IconButton(
              onPressed: (){print('object');},
              icon: Icon(Icons.download) ,
              color: Colors.grey,)

          ],
        )
      ],
    );
  }
}







