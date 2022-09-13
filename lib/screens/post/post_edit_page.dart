// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'dart:io';

import 'package:coralz/config/app.dart';
import 'package:coralz/config/token.dart';
import 'package:coralz/screens/home/app_bar.dart';
import 'package:coralz/screens/home/shimmer_loading.dart';
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

class PostEditPage extends StatefulWidget {
  final String id;
  const PostEditPage(this.id, {Key? key}) : super(key: key);

  @override
  State<PostEditPage> createState() => _PostEditPageState();
}

class _PostEditPageState extends State<PostEditPage> {
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
          Expanded(child: PostForm(widget.id))
        ],
      ),
    );
  }
}

class PostForm extends StatefulWidget {
  final String id;
  const PostForm(this.id, {Key? key}) : super(key: key);

  @override
  State<PostForm> createState() => _PostFormState();
}

class PostImage {
  XFile? image;
  String? postImage;
  String? postImageId;

  PostImage({this.image, this.postImage, this.postImageId});
}

class Category {
  int id;
  String name;
  Category(this.id, this.name);
}

class Post {
  String id;
  String user_id;
  String title;
  String description;
  String price;
  String delivery_price;
  String country;
  String delivery;
  String collection;
  String start_date;
  String end_date;
  String type;
  Post(
      this.id,
      this.user_id,
      this.title,
      this.description,
      this.price,
      this.delivery_price,
      this.country,
      this.delivery,
      this.collection,
      this.start_date,
      this.end_date,
      this.type);
}

class _PostFormState extends State<PostForm> {
  List files = [1, 2, 3];
  final ImagePicker _picker = ImagePicker();
  DateTime initialDate = DateTime.now();
  bool isLoading = false;
  bool isSubmit = false;

  // Params
  List<Category> data = [];
  int category_id = 0;
  DateTime selectedDate = DateTime.now();
  String countryValue = 'Click to select';
  String stateValue = '';
  String cityValue = '';
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController delivery_price = TextEditingController();
  int delivery = 0;
  int collection = 0;

  // Errors
  String? titleError, priceError, deliveryPriceError;

  int duration = 1;
  void setDuration(int d) {
    if (mounted) {
      setState(() {
        duration = d;
      });
    }
  }

  ButtonStyle durationActive(int d) {
    if (duration == d) {
      return ElevatedButton.styleFrom(
          primary: primaryColorRGB(1), elevation: 6);
    }

    return ElevatedButton.styleFrom(
        primary: Colors.white, onPrimary: Colors.black, elevation: 6);
  }

  // List<XFile> images = [];
  List<PostImage> images = [];
  Future<void> pickImage() async {
    if (images.length < 3) {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (mounted) {
          setState(() {
            images.add(PostImage(image: image));
          });
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: AwesomeSnackbarContent(
          title: 'Warning!',
          message: 'You can only select 3 image!',
          contentType: ContentType.warning,
        ),
      ));
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: initialDate,
        lastDate: DateTime(2050));
    if (selected != null && selected != selectedDate && mounted) {
      setState(() {
        selectedDate = selected;
      });
    }
  }

  displayDialog(int index, BuildContext context) {
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
                          images.removeAt(index);
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
                child: images[index].postImageId == null
                    ? Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            image: DecorationImage(
                                image:
                                    Image.file(File(images[index].image!.path))
                                        .image,
                                fit: BoxFit.contain)),
                      )
                    : CachedNetworkImage(
                        imageUrl: images[index].postImage!,
                        imageBuilder: (context, imageProvider) => Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    fit: BoxFit.contain,
                                    image: imageProvider))),
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

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  bool submitForm = false;
  Future<void> _storePost(BuildContext context) async {
    if (mounted) {
      setState(() {
        isSubmit = true;
        titleError = null;
        priceError = null;
        deliveryPriceError = null;
      });
    }

    try {
      String? token = await getBearerToken();

      var request = http.MultipartRequest(
          "POST", Uri.parse(api_endpoint + "api/v1/post/update/${widget.id}"));
      request.headers['Authorization'] = "Bearer " + token!;
      List<String> post_not_delete_image_ids = [];
      
      images.forEach((element) {
        if (element.postImageId == null) {
          Img.Image? image_temp =
              Img.decodeImage(File(element.image!.path).readAsBytesSync());
          if (image_temp == null) {
            return;
          }
          Img.Image resized_img = Img.copyResize(image_temp, width: 400);

          request.files.add(http.MultipartFile.fromBytes(
              'images[]', Img.encodeJpg(resized_img),
              filename: 'resized_image.jpg',
              contentType: MediaType.parse('image/jpeg')));
        } else {
          post_not_delete_image_ids.add(element.postImageId!);
        }
      });

      request.fields['title'] = title.text;
      request.fields['description'] = description.text;
      request.fields['price'] = price.text;
      request.fields['duration'] = duration.toString();
      request.fields['start_date'] =
          "${selectedDate.year}-${selectedDate.month}-${selectedDate.day}";
      request.fields['country'] = countryValue;
      request.fields['delivery_price'] =
          delivery_price.text.isNotEmpty ? delivery_price.text : '0';
      request.fields['delivery'] = delivery.toString();
      request.fields['collection'] = collection.toString();
      request.fields['post_not_delete_image_ids'] = post_not_delete_image_ids.join(",");
      

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      print(response.statusCode);
      if (response.statusCode == 200) {
        var result = String.fromCharCodes(responseData);
        var response = jsonDecode(result);
        print(response);
        if (response['status']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Success!',
                message: 'Successfully Posted!',
                contentType: ContentType.success,
              ),
            ));
          }
        } else {
          if (response['errors']['type'] == 1) {
            var errors = response['errors']['errors'];

            if (mounted) {
              setState(() {
                if (errors.containsKey('title')) {
                  titleError = errors['title'][0];
                }
                if (errors.containsKey('price')) {
                  priceError = errors['price'][0];
                }
                if (errors.containsKey('delivery_price')) {
                  deliveryPriceError = errors['delivery_price'][0];
                }
                if (errors.containsKey('images.0')) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Error!',
                      message: 'Image no 1 is not correct!',
                      contentType: ContentType.failure,
                    ),
                  ));
                }
                if (errors.containsKey('images.1')) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Error!',
                      message: 'Image no 2 is not correct!',
                      contentType: ContentType.failure,
                    ),
                  ));
                }
                if (errors.containsKey('images.2')) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    elevation: 0,
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    content: AwesomeSnackbarContent(
                      title: 'Error!',
                      message: 'Image no 3 is not correct!',
                      contentType: ContentType.failure,
                    ),
                  ));
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
      print(e.toString());
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
        isSubmit = false;
      });
    }
  }

  late Post post;
  Future<void> _loadData(BuildContext context) async {
    print("Start");
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      String? token = await getBearerToken();
      var result = await http.get(
          Uri.parse(api_endpoint + "api/v1/edit-post/${widget.id}"),
          headers: {"Authorization": "Bearer " + token!});
      if (result.statusCode == 200) {
        var response = jsonDecode(result.body);
        if (response['status']) {
          if (mounted) {
            if (response['data']['images'] != null) {
              response['data']['images'].forEach((k) {
                images.add(PostImage(
                    postImage: api_endpoint + k['image'].toString(),
                    postImageId: k['id'].toString()));
              });
            }

            setState(() {
              // DateTime selectedDate = DateTime.now();
              countryValue = response['data']['country'] ?? 'None';
              title.text = response['data']['title'];
              description.text = response['data']['description'] ?? '';
              price.text = response['data']['price'].toString();
              delivery_price.text =
                  response['data']['delivery_price'].toString();
              delivery = response['data']['delivery'] == 1 ? 1 : 0;
              collection = response['data']['collection'] == 1 ? 1 : 0;
              initialDate = DateTime.parse(response['data']['start_date']);
              selectedDate = DateTime.parse(response['data']['start_date']);
              int d = daysBetween(
                  selectedDate, DateTime.parse(response['data']['end_date']));
              if ([1, 3, 5, 7, 10, 14].contains(d)) {
                duration = d;
              }
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
            padding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 30),
            child: Column(
              children: [
                GridView.builder(
                    padding: EdgeInsets.all(0),
                    shrinkWrap: true,
                    itemCount: images.length + 1,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    itemBuilder: ((context, index) {
                      if (index != images.length) {
                        return GestureDetector(
                          onTap: () {
                            if (mounted) {
                              displayDialog(index, context);
                            }
                          },
                          child: images[index].postImageId == null
                              ? Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      image: DecorationImage(
                                          image: Image.file(File(
                                                  images[index].image!.path))
                                              .image,
                                          fit: BoxFit.fill)),
                                )
                              : CachedNetworkImage(
                                  imageUrl: images[index].postImage!,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image: imageProvider))),
                                  placeholder: (context, url) => Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: AssetImage(
                                                  "assets/images/image_loader.gif")))),
                                  errorWidget: (context, url, error) => Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image:
                                                  AssetImage("assets/images/image_not_found.png"))))),
                        );
                      }
                      return GestureDetector(
                        onTap: () {
                          pickImage();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: Colors.grey.shade400)),
                          child: Icon(
                            Icons.add_a_photo,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      );
                    })),
                SizedBox(
                  height: 15,
                ),
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
                          cursorColor: primaryColorRGB(1),
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
                          cursorColor: primaryColorRGB(1),
                          maxLines: 5,
                          minLines: 4,
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
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Price",
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
                          controller: price,
                          cursorColor: primaryColorRGB(1),
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.currency_pound,
                              color: Color.fromRGBO(106, 106, 106, 1),
                            ),
                            hintText: 'Type..',
                            focusColor: primaryColorRGB(1),
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
                priceError != null
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          priceError!,
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
                      Row(
                        children: [
                          Text(
                            "Select Country",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 6,
                        shadowColor: Colors.grey.shade500,
                        child: ListTile(
                          title: Text(countryValue),
                          trailing: Icon(Icons.arrow_drop_down),
                          onTap: () {
                            showCountryPicker(
                              context: context,
                              showPhoneCode:
                                  false, // optional. Shows phone code before the country name.
                              onSelect: (Country country) {
                                if (mounted) {
                                  setState(() {
                                    countryValue = country.name;
                                  });
                                }
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 6,
                        shadowColor: Colors.grey.shade500,
                        child: ListTile(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                if (delivery == 1) {
                                  delivery = 0;
                                } else {
                                  delivery = 1;
                                }
                              });
                            }
                          },
                          title: Text(
                            'Delivery',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(
                            delivery == 1
                                ? Icons.check_box
                                : Icons.check_box_outline_blank_outlined,
                            color: primaryColorRGB(1),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 6,
                        shadowColor: Colors.grey.shade500,
                        child: TextFormField(
                          controller: delivery_price,
                          cursorColor: primaryColorRGB(1),
                          decoration: InputDecoration(
                            suffixIcon: Icon(
                              Icons.currency_pound,
                              color: Color.fromRGBO(106, 106, 106, 1),
                            ),
                            hintText: 'Delivery',
                            focusColor: primaryColorRGB(1),
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
                    ),
                  ],
                ),
                deliveryPriceError != null
                    ? Align(
                        alignment: Alignment.center,
                        child: Text(
                          deliveryPriceError!,
                          style: TextStyle(color: Colors.red),
                        ),
                      )
                    : Center(),
                SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 6,
                        shadowColor: Colors.grey.shade500,
                        child: ListTile(
                          onTap: () {
                            if (mounted) {
                              setState(() {
                                if (collection == 1) {
                                  collection = 0;
                                } else {
                                  collection = 1;
                                }
                              });
                            }
                          },
                          title: Text(
                            'Collection',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: Icon(
                            collection == 1
                                ? Icons.check_box
                                : Icons.check_box_outline_blank_outlined,
                            color: primaryColorRGB(1),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Start Date",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                          onPressed: () {
                            pickDate(context);
                          },
                          icon: Icon(
                            Icons.calendar_month,
                            size: 30,
                          )),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 6,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Duration",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade400),
                          ),
                          SizedBox(
                            height: 6,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton(
                                onPressed: () {
                                  setDuration(1);
                                },
                                child: Text('1 Day'),
                                style: durationActive(1),
                              )),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: ElevatedButton(
                                onPressed: () {
                                  setDuration(3);
                                },
                                child: Text('3 Day'),
                                style: durationActive(3),
                              )),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: ElevatedButton(
                                onPressed: () {
                                  setDuration(5);
                                },
                                child: Text('5 Day'),
                                style: durationActive(5),
                              )),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                  child: ElevatedButton(
                                onPressed: () {
                                  setDuration(7);
                                },
                                child: Text('7 Day'),
                                style: durationActive(7),
                              )),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: ElevatedButton(
                                onPressed: () {
                                  setDuration(10);
                                },
                                child: Text('10 Day'),
                                style: durationActive(10),
                              )),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                  child: ElevatedButton(
                                      onPressed: () {
                                        setDuration(14);
                                      },
                                      child: Text('14 Day'),
                                      style: durationActive(14))),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                isSubmit
                    ? CircularProgressIndicator(
                        color: primaryColorRGB(1),
                      )
                    : Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(70, 0, 70, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            _storePost(context);
                          },
                          child: Text('Post'),
                          style: ElevatedButton.styleFrom(
                            primary: primaryColorRGB(1),
                            elevation: 6,
                            padding: EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                          ),
                        )),
                SizedBox(
                  height: 5,
                ),
                Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(70, 0, 70, 0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                      style: ElevatedButton.styleFrom(
                          primary: secondaryColorRGB(1),
                          padding: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          elevation: 6),
                    )),
              ],
            ),
          );
  }
}
