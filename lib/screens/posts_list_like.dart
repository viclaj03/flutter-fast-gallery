

import 'dart:ui';

import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/providers/post_data.dart';
import 'package:fastgalery/screens/form_post.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';



ApiService apiService = ApiService();
int _currentPage = 1;





int calculateCrossAxisCount(BuildContext context) {
  double screenWidth = MediaQuery.of(context).size.width;

  if (screenWidth < 300) {
    return 1; // Dispositivos muy pequeños, una sola columna
  } else if (screenWidth < 600) {
    return 2; // Dispositivos pequeños, dos columnas
  } else if (screenWidth < 800) {
    return 3; // Dispositivos medianos, tres columnas
  } else {
    return 4; // Dispositivos grandes, cuatro columnas
  }
}

class ListImagesLikeScreen extends StatefulWidget {

  ListImagesLikeScreen({super.key});

  @override
  _ListImagesLikeScreenState createState() => _ListImagesLikeScreenState();


}

class _ListImagesLikeScreenState extends State<ListImagesLikeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PostData _postData = PostData.fromJson('[]');


  _ListImagesLikeScreenState();

  // Página inicial

  @override
  void initState() {
    super.initState();
    _refresh();
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
      final jsonData = await apiService.getImageListLike(_currentPage);
      final newData = PostData.fromJson(jsonData);
      if (newData.getSize() > 0) {
        setState(() {
          PostData.addMoreData(_postData, newData);
          _currentPage++;
        });
      } else {
        print('sin posts');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya no hay más posts :(',),showCloseIcon: true,
            backgroundColor: Colors.red,duration: Duration(seconds: 2),shape: StadiumBorder(),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }
  }

  Future<void> _refresh() async {
    // Lógica de actualización al hacer "pull-to-refresh"
    _currentPage = 1;
    _postData.Clear(); // Asegúrate de limpiar la lista actual
    await _loadData();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text('Favoritos'),
          gradientColors:const [
            Color(0xff611de1),
            Color(0xffa74bc0),
          ]
      ),
      body:   imageList(),

    );
  }


  Widget imageList(){
    return RefreshIndicator(
      onRefresh: _refresh,
      child: GridView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: calculateCrossAxisCount(context), // Puedes ajustar el número de columnas según tu preferencia
          crossAxisSpacing: 8.0, // Espaciado horizontal entre elementos
          mainAxisSpacing: 8.0, // Espaciado vertical entre elementos
        ),
        controller: _scrollController,
        itemCount: _postData.getSize(),
        itemBuilder: (context, index) {
          final post = _postData.getPost(index);
          return  imageView(post);
        },
      ),
    );
  }

  Widget imageView(Post post){
    return InkWell(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            textDirection: TextDirection.rtl,
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),

                  child: !post.NSFW?ImageFiltered(
                      imageFilter: post.NSFW? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0):ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child:Hero(
                          tag:'imageHero${post.id}',
                          child:Image.network(
                            '${apiService.baseUrl}/static/images_render/${post.image_url_ligere}',
                          ))):
                  ColorFiltered(
                      colorFilter: ColorFilter.mode(Color(0xABD7322F), BlendMode.lighten),
                      child:
                      ImageFiltered(
                          imageFilter: post.NSFW? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0):ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child:Hero(
                              tag:'imageHero${post.id}',
                              child:Image.network(
                                '${apiService.baseUrl}/static/images_render/${post.image_url_ligere}',

                              )))),
                ),
              ),
              Text(post.title) ,
            ],
          )
        ],
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen(post)));
      },
    );
  }
}





