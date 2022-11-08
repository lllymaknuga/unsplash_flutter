import 'package:unsplash_flutter/repositories/api_base.dart';
import 'package:unsplash_flutter/repositories/types.dart';

abstract class AbstractAPIRepository {
  final APIRepository _apiRepository;
  final String _path;
  final QueryParams _defaultQueryParams;

  String _getPath({String? id}) {
    String path = _path;
    if (id != null) {
      path = '$path/$id';
    }
    return path;
  }

  QueryParams? _getQueryParams(QueryParams? queryParams) {
    if (queryParams == null) {
      return _defaultQueryParams;
    } else {
      return QueryParams.from(_defaultQueryParams)..addAll(queryParams);
    }
  }

  AbstractAPIRepository({
    required APIRepository apiRepository,
    required String path,
    QueryParams defaultQueryParams = const {},
  })  : _apiRepository = apiRepository,
        _path = path,
        _defaultQueryParams = defaultQueryParams;
}

mixin GetMixin<M> on AbstractAPIRepository {
  Future<M?> get(String id, {QueryParams? queryParams}) async {
    final json = await _apiRepository.get(
      _getPath(),
      queryParams: _getQueryParams(queryParams),
    );
    return parse(json);
  }

  M? parse(Map<String, dynamic> data);
}
mixin PaginatedListMixin<M> on AbstractAPIRepository {
  Future<List<M>> getPage({QueryParams? queryParams}) async {
    final page = await _apiRepository.page(
      _path,
      queryParams: _getQueryParams(queryParams),
    );
    return page.map((e) => parse(e)).toList();
  }

  M parse(Map<String, dynamic> data);
}
