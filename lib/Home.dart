import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:app1/packs/imageWork.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_v3/image_gallery_saver.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late ImageProvider image1;
  late ImageProvider image2;
  ImageProvider? _image;

  ImageWork imageWork = ImageWork();

  teste() async {
    final directory = await getApplicationDocumentsDirectory();
    /*Image img1 = await imageWork
        .loadImage('/data/user/0/com.example.app1/app_flutter/newImage.png');
    Image img2 = await imageWork
        .loadImage('/data/user/0/com.example.app1/app_flutter/newImage.png');*/
    // '${directory.path}/image.png'
    // _image = await imageWork.makeImage(Image.asset('images/moeda_cara.png'),
    //     Image.asset('images/moeda_cara.png'));
    print("teste 000");
    //_image = await imageWork.toBinary(Image.asset('images/moeda_cara.png'));
    _image = await imageWork.toBinary(Image.network(
        "https://cdn.pixabay.com/photo/2023/01/24/13/23/viet-nam-7741017_640.jpg"));

    //Image.asset('images/moeda_cara.png')
    imageWork.saveImage(_image!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //loadImage();
    print("teste Init");
    teste();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Combine Images"),
      ),
      body: Center(
        child: _image == null
            ? CircularProgressIndicator()
            : Image(image: _image!),
      ),
    );
  }
}
