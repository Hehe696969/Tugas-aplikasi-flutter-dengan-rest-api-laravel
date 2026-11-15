import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../viewmodels/book_vm.dart';

class BookListView extends ConsumerStatefulWidget {
  const BookListView({super.key});

  @override
  ConsumerState<BookListView> createState() => _BookListViewState();
}

class _BookListViewState extends ConsumerState<BookListView> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(bookProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Buku'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(bookProvider.notifier).load();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(bookProvider.notifier).load(),
        child: Builder(
          builder: (context) {
            if (bookState.loading && bookState.books.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (bookState.error != null &&
                bookState.books.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 150),
                  Center(
                    child: Text(bookState.error!),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ref.read(bookProvider.notifier).load();
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ),
                ],
              );
            }

            if (bookState.books.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 180),
                  Center(
                    child: Text('Belum ada data buku.'),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: bookState.books.length,
              itemBuilder: (context, index) {
                final book = bookState.books[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.menu_book),
                    ),
                    title: Text(book.title),
                    subtitle: Text(
                      '${book.author}\n'
                      'Penerbit: ${book.publisher ?? "-"}\n'
                      'Tahun: ${book.publishedYear}\n'
                      'Stok: ${book.stock}',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
