import 'package:unsplash_flutter/models/picture.dart';
import 'package:unsplash_flutter/repositories/api_base.dart';
import 'package:unsplash_flutter/repositories/api_mixins.dart';
import 'package:unsplash_flutter/repositories/types.dart';

class PictureAPIRepository extends AbstractAPIRepository
    with PaginatedListMixin<PictureModel> {
  static const _prefix = '/photos';

  PictureAPIRepository({
    required APIRepository apiRepository,
    QueryParams defaultQueryParams = const {},
  }) : super(
            apiRepository: apiRepository,
            path: _prefix,
            defaultQueryParams: defaultQueryParams);

  @override
  PictureModel parse(Map<String, dynamic> data) {
    return PictureModel.fromJson(data);
  }
}
