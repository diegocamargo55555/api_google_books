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
  bool _isLoadingMore = false;
  String _errorMessage = '';
  SearchType _searchType = SearchType.title;
  int _startIndex = 0;

  Future<void> _performSearch() async {
    final query = _controller.text;
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _books = [];
      _startIndex = 0;
    });

    try {
      final books = await _bookService.searchBooks(
        query: query,
        type: _searchType,
        startIndex: _startIndex,
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

  Future<void> _loadMoreBooks() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      _startIndex += 10;

      final moreBooks = await _bookService.searchBooks(
        query: _controller.text,
        type: _searchType,
        startIndex: _startIndex,
      );

      setState(() {
        _books.addAll(moreBooks);

        if (moreBooks.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Não há mais livros para carregar.')),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar mais: $e')));
    } finally {
      setState(() {
        _isLoadingMore = false;
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fundo.jpeg'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Column(
          children: [
            // Barra de pesquisa
            Container(
              padding: const EdgeInsets.all(16.0),
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

            // Resultados
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage))
                  : ListView.separated(
                      itemCount: _books.length + (_books.isNotEmpty ? 1 : 0),
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        if (index == _books.length) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _isLoadingMore
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : ElevatedButton(
                                    onPressed: _loadMoreBooks,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                    ),
                                    child: const Text('Carregar Mais'),
                                  ),
                          );
                        }

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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    BookDetailPage(book: book),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fundo.jpeg'),
            fit: BoxFit.cover,
            opacity: 0.3, // Mantendo a mesma opacidade da tela de busca
          ),
        ),
        child: SingleChildScrollView(
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
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Por: ${book.authors}',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
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
      ),
    );
  }
}
