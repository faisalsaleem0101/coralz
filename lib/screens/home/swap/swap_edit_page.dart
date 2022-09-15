import 'dart:convert';
import 'dart:io';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
import 'package:coralz/screens/home/swap/swap_view_page.dart';
import 'package:coralz/screens/post/post_view_page.dart';
import 'package:coralz/screens/theme/colors.dart';
import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_picker/country_picker.dart';

import 'package:image/image.dart' as Img;
import 'package:http_parser/http_parser.dart';

class SwapEditPage extends StatefulWidget {
  final String id;
  const SwapEditPage(this.id, {Key? key}) : super(key: key);

  @override
  State<SwapEditPage> createState() => _SwapEditPageState();
}

class _SwapEditPageState extends State<SwapEditPage> {
  bool isLoading = false;
  List data = [];
  final double _headerHeight = 220;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: _headerHeight,
            child: AppBarWidget(_headerHeight, true, Icons.person),
          ),
          Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Container(
                  alignment: Alignment.centerLeft,
                  child: BackButton(
                    color: Colors.black,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )),
                Expanded(
                  child: Container(
                      alignment: Alignment.topCenter,
                      child: FittedBox(
                        child: Text(
                          'Edit',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ),
                Expanded(
                    child: Container(
                  alignment: Alignment.centerRight,
                ))
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Expanded(child: SwapForm(widget.id))
        ],
      ),
    );
  }
}

class SwapForm extends StatefulWidget {
  final String id;
  const SwapForm(this.id, {Key? key}) : super(key: key);

  @override
  State<SwapForm> createState() => _SwapFormState();
}

class _SwapFormState extends State<SwapForm> {
  final double _headerHeight = 220;
  final TextEditingController title = TextEditingController();
  final TextEditingController wanted = TextEditingController();
  final TextEditingController description = TextEditingController();
  final TextEditingController offered = TextEditingController();
  String? titleError, wantedError, offeredError;
  XFile? attach_image;
  String? post_image;

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = (await _picker.pickImage(source: ImageSource.gallery));

    if (mounted && image != null) {
      setState(() {
        attach_image = image;
      });
    }
  }

  displayDialog(File file, BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
            child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          attach_image = null;
                        });
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ))
                ],
              ),
              Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                              fit: BoxFit.contain,
                              image: Image.file(file).image))))
            ],
          ),
        ));
      },
    );
  }

  displayNetworkImageDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
            child: Scaffold(
          backgroundColor: Colors.black,
          body: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      )),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          post_image = null;
                        });
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ))
                ],
              ),
              Expanded(
                child: CachedNetworkImage(
                    imageUrl: api_endpoint + post_image!,
                    imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                fit: BoxFit.contain, image: imageProvider))),
                    placeholder: (context, url) => Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage(
                                    "assets/images/image_loader.gif")))),
                    errorWidget: (context, url, error) => Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                                fit: BoxFit.contain,
                                image: AssetImage(
                                    "assets/images/image_not_found.png"))))),
              )
            ],
          ),
        ));
      },
    );
  }

  bool isLoading = false;

  Future<void> _swapStore(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
        titleError = null;
        wantedError = null;
        offeredError = null;
      });
    }

    try {
      String? token = await getBearerToken();

      var request = http.MultipartRequest(
          "POST", Uri.parse(api_endpoint + "api/v1/update-swap/${widget.id}"));
      request.headers['Authorization'] = "Bearer " + token!;
      if (attach_image != null) {
        // // resized Image
        // Img.Image? image_temp =
        //     Img.decodeImage(File(attach_image!.path).readAsBytesSync());
        // if (image_temp == null) {
        //   return;
        // }
        // Img.Image resized_img = Img.copyResize(image_temp, width: 300);
        // // End

        // request.files.add(http.MultipartFile.fromBytes(
        //     'image', Img.encodeJpg(resized_img),
        //     filename: 'resized_image.jpg',
        //     contentType: MediaType.parse('image/jpeg')));

        request.files.add(http.MultipartFile.fromBytes(
            'image', File(attach_image!.path).readAsBytesSync(),
            filename: attach_image!.path));
      }
      request.fields['title'] = title.text;
      request.fields['wanted'] = wanted.text;
      request.fields['offered'] = offered.text;
      request.fields['description'] = description.text;
      request.fields['remove_image'] = post_image == null ? '1' : '0';

      var response = await request.send();
      var responseData = await response.stream.toBytes();

      if (response.statusCode == 200) {
        var result = String.fromCharCodes(responseData);
        var response = jsonDecode(result);
        if (response['status']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Success!',
                message: 'Saved!',
                contentType: ContentType.success,
              ),
            ));
          }

          Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) =>
                  SwapPostViewPage(response['swap_id'].toString())));
        } else {
          if (response['errors']['type'] == 1) {
            var errors = response['errors']['errors'];

            if (mounted) {
              setState(() {
                if (errors.containsKey('title')) {
                  titleError = errors['title'][0];
                }
                if (errors.containsKey('offered')) {
                  offeredError = errors['offered'][0];
                }
                if (errors.containsKey('wanted')) {
                  wantedError = errors['wanted'][0];
                }
              });
            }
          } else {
            if (mounted)
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                elevation: 0,
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.transparent,
                content: AwesomeSnackbarContent(
                  title: 'Error!',
                  message: 'Something went wrong!',
                  contentType: ContentType.failure,
                ),
              ));
          }
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Error!',
              message: 'Something went wrong!',
              contentType: ContentType.failure,
            ),
          ));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          content: AwesomeSnackbarContent(
            title: 'Error!',
            message: 'Something went wrong!',
            contentType: ContentType.failure,
          ),
        ));
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadData(BuildContext context) async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(
          Uri.parse(api_endpoint + "api/v1/swap/${widget.id}"),
          headers: {"Authorization": "Bearer " + token!});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if (response['status']) {
          if (mounted) {
            setState(() {
              title.text = response['data']['title'];
              description.text = response['data']['description'] ?? '';
              wanted.text = response['data']['wanted'];
              offered.text = response['data']['offered'];
              post_image = response['data']['image'];
            });
          }
        }
      }
    } catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(context));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child: CircularProgressIndicator(color: primaryColorRGB(1)),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 25),
            child: Container(
              padding: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Column(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Title",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          shadowColor: Colors.grey.shade500,
                          child: TextFormField(
                            controller: title,
                            decoration: InputDecoration(
                              hintText: 'Text...',
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  titleError != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            titleError!,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : Center(),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Wanted",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          shadowColor: Colors.grey.shade500,
                          child: TextFormField(
                            controller: wanted,
                            decoration: InputDecoration(
                              hintText: 'Text...',
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  wantedError != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            wantedError!,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : Center(),
                  SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      post_image != null
                          ? GestureDetector(
                              onTap: () {
                                displayNetworkImageDialog(context);
                              },
                              child: CachedNetworkImage(
                                  imageUrl: api_endpoint + post_image!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                                image: imageProvider,
                                                fit: BoxFit.fill)),
                                      ),
                                  placeholder: (context, url) => Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/image_loader.gif"),
                                                fit: BoxFit.fill)),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/image_not_found.png"),
                                                fit: BoxFit.fill)),
                                      )),
                            )
                          : attach_image != null
                              ? GestureDetector(
                                  onTap: () {
                                    displayDialog(
                                        File(attach_image!.path), context);
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        image: DecorationImage(
                                            image: Image.file(
                                                    File(attach_image!.path))
                                                .image,
                                            fit: BoxFit.fill)),
                                  ),
                                )
                              : GestureDetector(
                                  onTap: () {
                                    pickImage();
                                  },
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                        border: Border.all(
                                            color: Colors.grey.shade400)),
                                    child: Icon(
                                      Icons.add_a_photo,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                )
                    ],
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Offered",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          shadowColor: Colors.grey.shade500,
                          child: TextFormField(
                            controller: offered,
                            decoration: InputDecoration(
                              hintText: 'Text...',
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  offeredError != null
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            offeredError!,
                            style: TextStyle(color: Colors.red),
                          ),
                        )
                      : Center(),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 6,
                          shadowColor: Colors.grey.shade500,
                          child: TextFormField(
                            controller: description,
                            minLines: 5,
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: 'Text...',
                              hintStyle: TextStyle(fontWeight: FontWeight.bold),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                  left: 15, bottom: 11, top: 11, right: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  !isLoading
                      ? FractionallySizedBox(
                          alignment: Alignment.topCenter,
                          widthFactor: 0.6,
                          child: Container(
                              margin: EdgeInsets.only(top: 20),
                              child: ElevatedButton(
                                onPressed: () {
                                  _swapStore(context);
                                },
                                child: Text('Save'),
                                style: ElevatedButton.styleFrom(
                                    primary: secondaryColorRGB(1),
                                    padding: EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(50)),
                                    elevation: 6),
                              )),
                        )
                      : Container(
                          margin: EdgeInsets.only(top: 20),
                          child: CircularProgressIndicator(
                            color: secondaryColorRGB(1),
                          ),
                        ),
                ],
              ),
            ),
          );
  }
}
