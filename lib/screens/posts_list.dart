

import 'dart:ui';

import 'package:fastgalery/customWidgest/grandient_app_bar.dart';
import 'package:fastgalery/model/post.dart';
import 'package:fastgalery/providers/post_data.dart';
import 'package:fastgalery/providers/shared_preferences.dart';
import 'package:fastgalery/screens/form_post.dart';
import 'package:fastgalery/screens/message_list.dart';
import 'package:fastgalery/screens/post_show.dart';

import 'package:fastgalery/screens/posts_list_like.dart';
import 'package:fastgalery/screens/profile.dart';

import 'package:fastgalery/screens/search_screen.dart';
import 'package:fastgalery/screens/settings.dart';
import 'package:fastgalery/screens/user_follow_list.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';

ApiService _apiService = ApiService();



int _currentPage = 1;

int _currentFollowPage = 1;

class CustomSearchDelegate extends SearchDelegate<String> {


  CustomSearchDelegate();


  @override
  List<Widget> buildActions(BuildContext context) {
    // Acciones para el campo de búsqueda (limpiar, cancelar, etc.)
    return [IconButton(icon: Icon(Icons.clear), onPressed: () => query = "")];
  }

  @override
  Widget buildLeading(BuildContext context) {
    // Icono a la izquierda del campo de búsqueda (generalmente, un ícono de atrás)
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, "");
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Muestra los resultados de la búsqueda
    return SearchListScreen();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Muestra sugerencias mientras escribes en el campo de búsqueda
    return Center(child: Text('Buscar post'));
  }
}



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

class PostsListScreen extends StatefulWidget {
  int id_user;
  PostsListScreen(this.id_user);

  @override
  _PostsListScreenState createState() => _PostsListScreenState(id_user);

}

class _PostsListScreenState extends State<PostsListScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final PostData _postData = PostData.fromJson('[]');
  final PostData _postDataFollow = PostData.fromJson('[]');
  late final TabController _tabController;



  int id_user;
  _PostsListScreenState(this.id_user);
  int _currentTabIndex = 1;



  // Página inicial

  @override
  void initState() {
    super.initState();
    _currentPage = 1;
    _loadData();
    _scrollController.addListener(_scrollListener);
    _tabController = TabController(length: 2, vsync: this,initialIndex: 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }





  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent ) {
      // Llegaste al final de la lista, carga más datos

      _loadData();
    }
  }

  Future<void> _loadData() async {

    var jsonData;
    var jsonDataFollow;
    var newData;
    var newDataFollow;
    try {
      print('pagina actual -> $_currentPage');
      print('pagina actual follow -> $_currentFollowPage');
      if(_currentTabIndex == 1){
        jsonData = await _apiService.getImageList(_currentPage);
        newData = PostData.fromJson(jsonData);
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

      } else {
        jsonDataFollow = await _apiService.getImageListByFollowing(_currentFollowPage);
        newDataFollow = PostData.fromJson(jsonDataFollow);
        if ( newDataFollow.getSize() > 0) {
          setState(() {
            PostData.addMoreData(_postDataFollow, newDataFollow);
            _currentFollowPage++;
          });
        } else {

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ya no hay más posts :(',),showCloseIcon: true,
              backgroundColor: Colors.red,duration: Duration(seconds: 2),shape: StadiumBorder(),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

      }
    } catch (e) {
      print('Error al cargar datos: $e');
    }

  }





_refreshs()  {

    _currentPage = 1;
    _currentFollowPage = 1;
    _postData.Clear();
    _postDataFollow.Clear();
    _loadData();
  }


  Future<void> _refreshAsync() async {

    _currentPage = 1;
    _currentFollowPage = 1;
    _postData.Clear();
    _postDataFollow.Clear();
     _loadData();
  }


  @override
  Widget build(BuildContext context) {

    _tabController.addListener(() {
      if (_tabController.index != _currentTabIndex) {
        // Solo si el índice actual del TabController es diferente al índice actual almacenado
        setState(() {
          _currentTabIndex = _tabController.index; // Actualiza el índice actual
          _refreshs(); // Llama a tu función de actualización de datos
        });
      }
    });


    return Scaffold(
          drawer: Drawer(
              child:Column(
                // Important: Remove any padding from the ListView.
                //padding: EdgeInsets.zero,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:  <Widget>[
                    const DrawerHeader(
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment(0.8, 1),
                            colors: <Color>[
                              Color(0xff611de1),
                              Color(0xffa74bc0),
                            ],tileMode: TileMode.mirror),
                        //color: Color(0xFF71B5EC),
                      ),
                      child:Text('FastGallery',style: TextStyle(fontSize: 50,color: Colors.white)),
                    ),

                    ListTile(
                      title:Row(
                        children: const [
                          Icon(Icons.person,size: 45),  // Aquí puedes cambiar Icons.person por el icono que prefieras
                          SizedBox(width: 10), // Añade un espacio entre el icono y el texto
                          Text('Perfil',style: TextStyle(fontSize: 25),),
                        ],
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(id_user: id_user)));
                      },
                    ),
                    ListTile(
                      title:Row(
                        children: const [
                          Icon(Icons.star,size: 45,color: Colors.amber),  // Aquí puedes cambiar Icons.person por el icono que prefieras
                          SizedBox(width: 10), // Añade un espacio entre el icono y el texto
                          Text('Favoritos',style: TextStyle(fontSize: 25),),
                        ],
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ListImagesLikeScreen()));
                      },

                    ),
                    ListTile(
                      title:Row(
                        children: const [
                          Icon(Icons.supervised_user_circle_sharp,size: 45,color: Colors.blue),  // Aquí puedes cambiar Icons.person por el icono que prefieras
                          SizedBox(width: 10), // Añade un espacio entre el icono y el texto
                          Text('Following users',style: TextStyle(fontSize: 20),),
                        ],
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ListUserFollowScreen()));
                      },
                    ),
                    ListTile(
                      title:Row(
                        children: const [
                          Icon(Icons.mail,size: 45,color: Colors.grey),  // Aquí puedes cambiar Icons.person por el icono que prefieras
                          SizedBox(width: 10), // Añade un espacio entre el icono y el texto
                          Text('Mensajes',style: TextStyle(fontSize: 25),),
                        ],
                      ),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MessageListScreen()));
                      },

                    ),
                    Expanded(
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              ListTile(
                                title:Row(
                                  children: const [
                                    Icon(Icons.settings,size: 25,color: Colors.grey),  // Aquí puedes cambiar Icons.person por el icono que prefieras
                                    SizedBox(width: 10), // Añade un espacio entre el icono y el texto
                                    Text('Settings',style: TextStyle(fontSize: 25),),
                                  ],
                                ),
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                                },
                              ),
                              ListTile(
                                title:Row(
                                  children: const [
                                    Icon(Icons.logout,size: 25,color: Colors.red),  // Aquí puedes cambiar Icons.person por el icono que prefieras
                                    SizedBox(width: 10), // Añade un espacio entre el icono y el texto
                                    Text('Logout',style: TextStyle(fontSize: 25,color: Colors.red),),
                                  ],
                                ),
                                onTap: (){
                                  removeToken();
                                  removeUserData();
                                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => ListImagesLikeScreen()));
                                },
                              ),
                            ],
                          ),
                        )
                    ),
                  ]
              )
          ),
          appBar: GradientAppBar(
            gradientColors:
            const <Color>[
              Color(0xff611de1),
              Color(0xffa74bc0),
            ],
            bottom: TabBar(
              isScrollable: false,
              physics: const NeverScrollableScrollPhysics(),
              controller: _tabController,


              tabs: const [
                Tab(
                  text: "Siguiendo",
                ),
                Tab(
                  text: "Todos",
                )
              ],
            ),
            title: Text('FastGallery'),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // Implementa la lógica de búsqueda aquí
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchListScreen()),
                  );
                  //showSearch(context: context, delegate: CustomSearchDelegate());
                },
              ),
            ],
          ),
          body:  TabBarView(
            controller: _tabController,
            children: [
            imageListFollow(),
            imageList(),
          ],) ,
          floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              tooltip: 'New Post',
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FormScreen()));
              }),
        )  ;
  }



  Widget imageListFollow(){
    return RefreshIndicator(
      onRefresh: _refreshAsync,
      child: GridView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: calculateCrossAxisCount(context),
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        controller: _scrollController,
        itemCount: _postDataFollow.getSize(),
        itemBuilder: (context, index) {
          final post = _postDataFollow.getPost(index);
          return  imageView(post);

        },
      ),
    );
  }


  Widget imageList(){
    return RefreshIndicator(
      onRefresh: _refreshAsync,
      child: GridView.builder(
        physics: AlwaysScrollableScrollPhysics(),
        gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: calculateCrossAxisCount(context),
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
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
                            '${_apiService.baseUrl}/static/images_render/${post.image_url_ligere}',
                          ))):
                  ColorFiltered(
                      colorFilter: ColorFilter.mode(Color(0xABD7322F), BlendMode.lighten),
                      child:
                      ImageFiltered(
                          imageFilter: post.NSFW? ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0):ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child:Hero(
                              tag:'imageHero${post.id}',
                              child:Image.network(
                                '${_apiService.baseUrl}/static/images_render/${post.image_url_ligere}',)
                          )
                      )
                  ),
                ),
              ),
              Text(post.title) ,
            ],
          )
        ],
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen(post))).then((result) =>
        {

          if(result != null && result is int){
            setState(() {
              _postData.deletePostById(result);
            })

          }
        });
      },
    );
  }
}





