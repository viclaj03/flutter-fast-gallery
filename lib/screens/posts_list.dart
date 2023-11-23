import 'package:fastgalery/providers/post_data.dart';
import 'package:fastgalery/screens/form_post.dart';
import 'package:fastgalery/screens/post_show.dart';
import 'package:fastgalery/services/api_services.dart';
import 'package:flutter/material.dart';

ApiService apiService = ApiService();

class PostsListScreen extends StatefulWidget {
  @override
  _PostsListScreenState createState() => _PostsListScreenState();
}

class _PostsListScreenState extends State<PostsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final PostData _postData = PostData.fromJson('[]');

  int _currentPage = 1; // Página inicial

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent ||
        _scrollController.position.pixels == _scrollController.position.minScrollExtent) {
      // Llegaste al final de la lista, carga más datos

      _loadData();
    }
  }

  Future<void> _loadData() async {
    try {
      print('pagina actual -> $_currentPage');
      final jsonData = await _apiService.getImageList(_currentPage);
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
      // Manejar el error
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
      appBar: AppBar(
        title: const Text('Fast Gallery'),
      ),
      body:   RefreshIndicator(
        onRefresh: _refresh,
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Puedes ajustar el número de columnas según tu preferencia
            crossAxisSpacing: 8.0, // Espaciado horizontal entre elementos
            mainAxisSpacing: 8.0, // Espaciado vertical entre elementos
          ),
          controller: _scrollController,
          itemCount: _postData.getSize(),
          itemBuilder: (context, index) {

            final post = _postData.getPost(index);
            return InkWell(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Hero(tag: 'imageHero${post.id}', child: Image.network('${apiService.baseUrl}/static/images/${post.image_url}'))
                ],
              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => PostScreen(post)));
              },
            );
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: 'Increment Counter',
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => FormScreen()));
          }),
    );
  }
}


