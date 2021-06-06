import 'dart:io';
import 'package:flutter/material.dart';
import 'package:custom_image_picker/custom_image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Gallery Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: ImageGallery(),
    );
  }
}

class ImageGallery extends StatefulWidget {
  const ImageGallery({Key key}) : super(key: key);

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<dynamic> imageList;

  Future<void> _getImages() async {
    final customImagePicker = CustomImagePicker();
    customImagePicker.getAllImages(callback: (dynamic retrievedImages) {
      setState(() {
        imageList = retrievedImages;
      });
    });
  }

  @override
  void initState() {
    _getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Gallery')),
      body: imageList != null
          ? GridView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: imageList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: .7,
              ),
              itemBuilder: (context, i) {
                String phoneAlbum = imageList[i];
                print(phoneAlbum);
                return Material(
                  elevation: 8.0,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            FullScreenImagePage(imagePath: phoneAlbum),
                      ),
                    ),
                    child: Hero(
                      tag: phoneAlbum,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            File(phoneAlbum),
                            fit: BoxFit.cover,
                          )),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;
  const FullScreenImagePage({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image View'),
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: Image.file(
            File(imagePath),
          ),
        ),
      ),
    );
  }
}
