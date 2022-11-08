import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:shimmer/shimmer.dart';
import 'package:unsplash_flutter/blocs/picture/bloc.dart';
import 'package:unsplash_flutter/extensions.dart';
import 'package:unsplash_flutter/models/picture.dart';
import 'package:unsplash_flutter/views/picture_page.dart';

class PicturesPage extends StatelessWidget {
  const PicturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (_) => PictureBloc()..add(const PictureFetched()),
        child: const _PicturesList(),
      ),
    );
  }
}

class _PicturesList extends StatefulWidget {
  const _PicturesList({Key? key}) : super(key: key);

  @override
  State<_PicturesList> createState() => _PicturesListState();
}

class _PicturesListState extends State<_PicturesList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) context.read<PictureBloc>().add(const PictureFetched());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll);
  }

  int countRow(int len, bool hasReachedMax) {
    if (len % 2 == 0) {
      return hasReachedMax ? len ~/ 2 : len ~/ 2 + 1;
    } else {
      return hasReachedMax ? len ~/ 2 + 1 : len ~/ 2 + 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05 / 2),
      child: BlocConsumer<PictureBloc, PictureState>(
        buildWhen: (_, current) {
          return !(current.status == PictureStatus.failure && current.pictures.isEmpty);
        },
          listener: (context, state) {
            if (state.pictures.isNotEmpty && state.status == PictureStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Something went wrong!'),
                    action: SnackBarAction(
                      label: 'Ok',
                      onPressed: () {
                      },
                    ),
                  )
              );
            }
          },
          builder: (context, state) {
            switch (state.status) {
              case PictureStatus.failure:
                return Center(
                    child: Column(
                  children: [
                    const Text('failed to fetch posts'),
                    ElevatedButton(
                      onPressed: () {
                        context.read<PictureBloc>().add(const PictureFetched());
                      },
                      child: const Text('Repeat'),
                    ),
                  ],
                ));
              case PictureStatus.success:
                if (state.pictures.isEmpty) {
                  return const Center(child: Text('no posts'));
                }
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    const SliverPersistentHeader(
                      pinned: true,
                      delegate: MySliverHeaderDelegate(),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: countRow(
                            state.pictures.length, state.hasReachedMax),
                        (context, index) {
                          if (state.pictures.length % 2 == 0) {
                            if (index + 1 == (state.pictures.length ~/ 2) + 1) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _PicturesRow(pictures: [
                                  state.pictures[2 * index],
                                  state.pictures[2 * index + 1]
                                ]),
                              );
                            }
                          } else {
                            if (index == state.pictures.length ~/ 2 + 1) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              if (index == state.pictures.length ~/ 2) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _PicturesRow(pictures: [
                                    state.pictures[2 * index],
                                  ]),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _PicturesRow(pictures: [
                                  state.pictures[2 * index],
                                  state.pictures[2 * index + 1]
                                ]),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ],
                );
              case PictureStatus.initial:
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    const SliverPersistentHeader(
                        pinned: true, delegate: MySliverHeaderDelegate()),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: 5,
                        (context, index) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: 10),
                            child: _RowsSkeleton(),
                          );
                        },
                      ),
                    ),
                  ],
                );
            }
          }),
    );
  }
}

class _PicturesRow extends StatelessWidget {
  final List<PictureModel> pictures;

  const _PicturesRow({Key? key, required this.pictures}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: pictures.map((e) => _PictureWidget(model: e)).toList(),
    );
  }
}

class _PictureWidget extends StatelessWidget {
  final PictureModel model;
  static const _digitCharacters =
      "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz#\$%*+,-.:;=?@[]^_{|}~";

  int _decode83(String str) {
    var value = 0;
    final units = str.codeUnits;
    final digits = _digitCharacters.codeUnits;
    for (var i = 0; i < units.length; i++) {
      final code = units.elementAt(i);
      final digit = digits.indexOf(code);
      if (digit == -1) {
        throw ArgumentError.value(str, 'str');
      }
      value = value * 83 + digit;
    }
    return value;
  }

  const _PictureWidget({Key? key, required this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final averageColorStr = model.blurHash.substring(2, 6);
    final averageColorInt = _decode83(averageColorStr);
    final averageColor = Color(0xFF000000 | averageColorInt);
    double width = MediaQuery.of(context).size.width;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40.0),
        boxShadow: [
          BoxShadow(
            color: averageColor,
            blurRadius: 6.0,
            spreadRadius: 0.0,
            offset: const Offset(
              0.0,
              3.0,
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(PicturePage.route(model: model));
        },
        child: Padding(
          padding: EdgeInsets.all(width * 0.01),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Stack(
              children: [
                CachedNetworkImage(
                  height: width * 0.44,
                  width: width * 0.44,
                  fit: BoxFit.fill,
                  imageUrl: model.urls.regular,
                  placeholder: (context, url) => BlurHash(hash: model.blurHash),
                ),
                Positioned(
                  left: 30,
                  bottom: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (model.user.username ?? 'unknown').capitalize(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Manrope',
                            fontSize: 15),
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      Text(
                        '${model.likes.toString()} likes',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BottomLoader extends StatelessWidget {
  const BottomLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(strokeWidth: 1.5),
      ),
    );
  }
}

class MySliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  const MySliverHeaderDelegate();

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
        child: Stack(
          children: [
            Align(
              alignment: Alignment(
                  -(kToolbarHeight - shrinkOffset) / kToolbarHeight, 0),
              child: const Text(
                'Photos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(covariant MySliverHeaderDelegate oldDelegate) {
    return oldDelegate != this;
  }
}

class _RowsSkeleton extends StatelessWidget {
  const _RowsSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[500]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.grey,
              width: width * 0.45,
              height: width * 0.45,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[500]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              color: Colors.grey,
              width: width * 0.45,
              height: width * 0.45,
            ),
          ),
        )
      ],
    );
  }
}
