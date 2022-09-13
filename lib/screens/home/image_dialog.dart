import 'package:cached_network_image/cached_network_image.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:flutter/material.dart';

class ImageDialog extends StatelessWidget {
  final String url;
  const ImageDialog(this.url);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: CachedNetworkImage(
          imageUrl: url,
          imageBuilder: (context, imageProvider) => Container(
                height: 400,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.contain)),
                child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        
                        backgroundColor: primaryColorRGB(1),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ),
          placeholder: (context, url) => Container(
                height: 400,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                        image: AssetImage('assets/images/image_loader.gif'),
                        fit: BoxFit.contain)),
                child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: primaryColorRGB(1),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    )),
              ),
          errorWidget: (context, url, error) => Container(
                height: 400,
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(
                        image: AssetImage('assets/images/image_not_found.png'),
                        fit: BoxFit.contain)),
                child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: primaryColorRGB(1),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    )),
              )),
    );
  }
}