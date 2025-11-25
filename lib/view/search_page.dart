import 'package:flutter/material.dart';
import 'package:livros_api_google/service/book_service.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final BookService _bookService = BookService();
  final TextEditingController _controller = TextEditingController();

  List<Book> _books = [];
  bool _isLoading = false;
  String _errorMessage = '';
  SearchType _searchType = SearchType.title;

  Future<void> _performSearch() async {
    final query = _controller.text;
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _books = [];
    });

    try {
      final books = await _bookService.searchBooks(
        query: query,
        type: _searchType,
      );

      setState(() {
        _books = books;
        if (books.isEmpty) {
          _errorMessage = 'Nenhum resultado encontrado.';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Busca de Livros'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // barra de pesquisa
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[50],
            child: Column(
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: _searchType == SearchType.title
                        ? 'Título do Livro'
                        : 'Nome do Autor',
                    hintText: 'Digite sua pesquisa...',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _performSearch,
                    ),
                  ),
                  onSubmitted: (_) => _performSearch(),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Radio<SearchType>(
                      value: SearchType.title,
                      groupValue: _searchType,
                      onChanged: (val) {
                        setState(() {
                          _searchType = val!;
                          _books.clear();
                          _errorMessage = '';
                        });
                      },
                    ),
                    const Text('Título'),
                    const SizedBox(width: 20),
                    Radio<SearchType>(
                      value: SearchType.author,
                      groupValue: _searchType,
                      onChanged: (val) {
                        setState(() {
                          _searchType = val!;
                          _books.clear();
                          _errorMessage = '';
                        });
                      },
                    ),
                    const Text('Autor'),
                  ],
                ),
              ],
            ),
          ),

          // resultados
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                ? Center(child: Text(_errorMessage))
                : ListView.separated(
                    itemCount: _books.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      return ListTile(
                        leading: book.capa.isNotEmpty
                            ? Image.network(
                                book.capa,
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.book,
                                size: 50,
                                color: Colors.grey,
                              ),
                        title: Text(
                          book.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(book.authors),
                        // abre o livro
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailPage(book: book),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class BookDetailPage extends StatelessWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Livro'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (book.capa.isNotEmpty)
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Image.network(
                    book.capa,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              book.title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Por: ${book.authors}',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Resumo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              book.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }
}
