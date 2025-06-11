import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_reads_flutter/screens/books/book_detail_screen.dart';
import 'package:hobby_reads_flutter/screens/shared/app_scaffold.dart';
import 'package:hobby_reads_flutter/provider/book_providers.dart';

class BooksScreen extends ConsumerStatefulWidget {
  const BooksScreen({super.key});

  @override
  ConsumerState<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends ConsumerState<BooksScreen> {
  final _searchController = TextEditingController();

  // List of placeholder image paths
  final List<String> _placeholderImages = const [
    'assets/images/book.jpg',
    'assets/images/hero.png',
    'assets/images/two.jpg',
    'assets/images/three.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Load books when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(booksProvider.notifier).loadBooks(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      ref.read(booksProvider.notifier).loadBooks(refresh: true);
    } else {
      ref.read(booksProvider.notifier).searchBooks(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(booksProvider);

    return AppScaffold(
      title: 'Books',
      currentRoute: '/books',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Books',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse and manage your book collection.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/add-book'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SearchBar(
                  controller: _searchController,
                  hintText: 'Search by title or author...',
                  leading: const Icon(Icons.search),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onSubmitted: _onSearch,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildBooksList(booksState),
          ),
        ],
      ),
    );
  }

  Widget _buildBooksList(BooksState booksState) {
    if (booksState.isLoading && booksState.books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (booksState.error != null && booksState.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Error loading books',
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(booksState.error!,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(booksProvider.notifier).loadBooks(refresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (booksState.books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No books found',
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('Try adjusting your search or add some books',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          ref.read(booksProvider.notifier).loadBooks(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: booksState.books.length,
        itemBuilder: (context, index) {
          final book = booksState.books[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailScreen(
                    bookId: book.id ?? 0,
                    book: book,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      image: book.coverImage != null
                          ? DecorationImage(
                              image: NetworkImage(book.coverImage!),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: book.coverImage == null
                        ? Center(
                            child: Image.asset(
                              _placeholderImages[
                                  index % _placeholderImages.length],
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.infinity,
                            ),
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.displayTitle,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('by ${book.displayAuthor}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600])),
                        if (book.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(book.description,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (book.genre != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(book.displayGenre,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).primaryColor)),
                              ),
                              const Spacer(),
                            ],
                            if (book.ownerName != null) ...[
                              Text('by ${book.ownerName}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[500])),
                            ] else if (book.createdAt != null) ...[
                              Text('Added ${book.createdAt!.year}',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey[500])),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
