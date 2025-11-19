import 'dart:convert';
import 'package:http/http.dart' as http;

enum SearchType { title, author }

class Book {
  //final String id;
  final String title;
  final String authors;
  final String capa;

  Book({
    //required this.id,
    required this.title,
    required this.authors,
    required this.capa,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    final volumeInfo = json['volumeInfo'];

    List<dynamic> authorsList = volumeInfo['authors'] ?? [];
    String authorsStr = authorsList.isNotEmpty
        ? authorsList.join(', ')
        : 'Autor desconhecido';

    String image = volumeInfo['imageLinks'] != null
        ? volumeInfo['imageLinks']['thumbnail']
        : '';

    return Book(
      //id: json['id'],
      title: volumeInfo['title'] ?? 'Sem título',
      authors: authorsStr,
      capa: image,
    );
  }
}

class BookService {
  Future<List<Book>> searchBooks({
    required String query,
    required SearchType type,
  }) async {
    http.Response response;
    if (query.isEmpty) return [];

    if (type == SearchType.title) {
      response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=intitle:$query',
        ),
      );
    } else {
      response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=inauthor:$query',
        ),
      );
    }

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['totalItems'] > 0 && data['items'] != null) {
        final List<dynamic> items = data['items'];
        return items.map((item) => Book.fromJson(item)).toList();
      } else {
        return [];
      }
    } else {
      throw Exception(
        'Erro ao conectar com o servidor: ${response.statusCode}',
      );
    }
  }
}
