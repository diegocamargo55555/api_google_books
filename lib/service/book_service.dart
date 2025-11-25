import 'dart:convert';
import 'package:http/http.dart' as http;

enum SearchType { title, author }

class Book {
  final String title;
  final String authors;
  final String capa;
  final String description; 

  Book({
    required this.title,
    required this.authors,
    required this.capa,
    required this.description, 
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
      title: volumeInfo['title'] ?? 'Sem título',
      authors: authorsStr,
      capa: image,
      description: volumeInfo['description'] ?? 'Sem descrição disponível.',
    );
  }
}

class BookService {
  Future<List<Book>> searchBooks({
    required String query,
    required SearchType type,
    int startIndex = 0,
  }) async {
    http.Response response;
    if (query.isEmpty) return [];

    if (type == SearchType.title) {
      response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=intitle:$query&startIndex=$startIndex',
        ),
      );
    } else {
      response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/books/v1/volumes?q=inauthor:$query&startIndex=$startIndex',
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
