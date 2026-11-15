import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

import '../core/network/api_exception.dart';
import '../models/book_model.dart';
import '../repositories/book_repository.dart';
import 'providers.dart';

class BookState {
  final List<BookModel> books;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final String search;
  final int currentPage;
  final int lastPage;
  final int total;

  const BookState({
    this.books = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.search = '',
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  bool get hasMore => currentPage < lastPage;

  BookState copyWith({
    List<BookModel>? books,
    bool? loading,
    bool? loadingMore,
    String? error,
    String? search,
    int? currentPage,
    int? lastPage,
    int? total,
    bool clearError = false,
  }) {
    return BookState(
      books: books ?? this.books,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
      search: search ?? this.search,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
    );
  }
}

class BookNotifier extends StateNotifier<BookState> {
  final BookRepository _repository;

  Timer? _searchDebounce;

  int _requestId = 0;

  BookNotifier(this._repository) : super(const BookState());

  // Pencarian dengan debounce 500 milidetik.
  void searchBooks(String keyword) {
    _searchDebounce?.cancel();

    // Batalkan validitas request sebelumnya.
    final requestId = ++_requestId;

    state = state.copyWith(
      loading: true,
      loadingMore: false,
      search: keyword,
      clearError: true,
    );

    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        _fetchBooks(keyword, requestId);
      },
    );
  }

  Future<void> load({String? search}) async {
    _searchDebounce?.cancel();

    final keyword = search ?? state.search;
    final requestId = ++_requestId;

    state = state.copyWith(
      loading: true,
      loadingMore: false,
      search: keyword,
      clearError: true,
    );

    await _fetchBooks(keyword, requestId);
  }

  Future<void> _fetchBooks(
    String keyword,
    int requestId,
  ) async {
    try {
      final result = await _repository.getBooks(
        search: keyword,
        page: 1,
      );

      // Abaikan respons dari request yang sudah kedaluwarsa.
      if (requestId != _requestId) return;

      state = state.copyWith(
        books: result.books,
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        loading: false,
        loadingMore: false,
        clearError: true,
      );
    } on ApiException catch (e) {
      if (requestId != _requestId) return;

      state = state.copyWith(
        loading: false,
        error: e.message,
      );
    } catch (e) {
      if (requestId != _requestId) return;

      state = state.copyWith(
        loading: false,
        error: 'Gagal memuat daftar buku.',
      );
    }
  }

  Future<String?> loadMore() async {
    if (state.loading ||
        state.loadingMore ||
        !state.hasMore) {
      return null;
    }

    final requestId = _requestId;
    final keyword = state.search;
    final nextPage = state.currentPage + 1;

    state = state.copyWith(loadingMore: true);

    try {
      final result = await _repository.getBooks(
        search: keyword,
        page: nextPage,
      );

      if (requestId != _requestId) return null;

      state = state.copyWith(
        books: [...state.books, ...result.books],
        currentPage: result.currentPage,
        lastPage: result.lastPage,
        total: result.total,
        loadingMore: false,
      );

      return null;
    } on ApiException catch (e) {
      if (requestId != _requestId) return null;

      state = state.copyWith(loadingMore: false);
      return e.message;
    } catch (e) {
      if (requestId != _requestId) return null;

      state = state.copyWith(loadingMore: false);
      return 'Gagal memuat halaman berikutnya.';
    }
  }

  Future<ApiException?> create(
    Map<String, dynamic> payload,
  ) async {
    try {
      await _repository.createBook(payload);
      await load();
      return null;
    } on ApiException catch (e) {
      return e;
    } catch (e) {
      return ApiException.from(e);
    }
  }

  Future<ApiException?> update(
    int id,
    Map<String, dynamic> payload,
  ) async {
    try {
      await _repository.updateBook(id, payload);
      await load();
      return null;
    } on ApiException catch (e) {
      return e;
    } catch (e) {
      return ApiException.from(e);
    }
  }

  Future<String?> delete(int id) async {
    try {
      await _repository.deleteBook(id);
      await load();
      return null;
    } on ApiException catch (e) {
      return e.message;
    } catch (e) {
      return 'Gagal menghapus buku.';
    }
  }

  void reset() {
    _searchDebounce?.cancel();
    _requestId++;
    state = const BookState();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}

final bookProvider =
    StateNotifierProvider<BookNotifier, BookState>(
  (ref) => BookNotifier(
    ref.read(bookRepositoryProvider),
  ),
);
