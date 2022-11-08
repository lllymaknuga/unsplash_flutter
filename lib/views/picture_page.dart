import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';
import 'package:unsplash_flutter/extensions.dart';
import 'package:unsplash_flutter/models/picture.dart';

class PicturePage extends StatelessWidget {
  final PictureModel model;

  const PicturePage({Key? key, required this.model}) : super(key: key);

  static Route route({required PictureModel model}) => MaterialPageRoute(
        builder: (_) => PicturePage(
          model: model,
        ),
      );

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    height: height * 0.6,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    imageUrl: model.urls.regular,
                    placeholder: (context, url) =>
                        BlurHash(hash: model.blurHash),
                  ),
                  Positioned(
                    top: 20,
                    left: 5,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Text(
                        '< Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (model.user.username ?? 'unknown').capitalize(),
                    style: const TextStyle(fontSize: 30),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${model.likes.toString()} likes',
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
