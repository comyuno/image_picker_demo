import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:custom_image_picker/custom_image_picker.dart';
import 'package:interactiveviewer_gallery/hero_dialog_route.dart';
import 'package:interactiveviewer_gallery/interactiveviewer_gallery.dart';
import 'package:video_player/video_player.dart';

class DemoSourceEntity {
  int id;
  String path;
  String type;
  String previewPath;

  DemoSourceEntity(this.id, this.type, this.path, {this.previewPath});
}

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
  static final String sName = "/";
  const ImageGallery({Key key}) : super(key: key);

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<DemoSourceEntity> imageList = [];

  Future<void> _getImages() async {
    List<DemoSourceEntity> demoList = [];
    final customImagePicker = CustomImagePicker();
    customImagePicker.getAllImages(callback: (dynamic retrievedImages) {
      for (int i = 0; i <= retrievedImages.length - 1; i++) {
        demoList.add(DemoSourceEntity(i, 'image', retrievedImages[i]));
      }
      setState(() {
        imageList = demoList;
      });
    });
  }

  void _openGallery(DemoSourceEntity source) {
    Navigator.of(context).push(
      HeroDialogRoute<void>(
        builder: (BuildContext context) =>
            InteractiveviewerGallery<DemoSourceEntity>(
          sources: imageList,
          initIndex: imageList.indexOf(source),
          itemBuilder: itemBuilder,
          onPageChanged: (int pageIndex) {
            print("nell-pageIndex:$pageIndex");
          },
        ),
      ),
    );
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
      body: imageList.isNotEmpty
          ? GridView.builder(
              padding: EdgeInsets.all(8.0),
              itemCount: imageList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
                childAspectRatio: .7,
              ),
              itemBuilder: (context, i) => _buildItem(imageList[i]),
            )
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildItem(DemoSourceEntity source) {
    return Hero(
      tag: source.id,
      // keep building the image since the images can be visible in the
      // background of the image gallery
      placeholderBuilder: (BuildContext context, Size heroSize, Widget child) {
        return child;
      },
      child: Material(
        elevation: 8.0,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
        child: InkWell(
          onTap: () => _openGallery(source),
          child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(source.path),
                fit: BoxFit.cover,
              )),
        ),
      ),
    );
  }

  Widget itemBuilder(BuildContext context, int index, bool isFocus) {
    DemoSourceEntity sourceEntity = imageList[index];
    if (sourceEntity.type == 'video') {
      return DemoVideoItem(
        sourceEntity,
        isFocus: isFocus,
      );
    } else {
      return DemoImageItem(sourceEntity);
    }
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

class DemoImageItem extends StatelessWidget {
  final DemoSourceEntity source;
  DemoImageItem(this.source);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Center(
        child: Hero(
          tag: source.id,
          child: Image.file(
            File(source.path),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class DemoVideoItem extends StatefulWidget {
  final DemoSourceEntity source;
  final bool isFocus;

  DemoVideoItem(this.source, {this.isFocus});

  @override
  _DemoVideoItemState createState() => _DemoVideoItemState();
}

class _DemoVideoItemState extends State<DemoVideoItem> {
  VideoPlayerController _controller;
  VoidCallback listener;
  String localFileName;

  _DemoVideoItemState() {
    listener = () {
      if (!mounted) {
        return;
      }
      setState(() {});
    };
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _controller = VideoPlayerController.network(widget.source.path);
    _controller.setLooping(true);
    await _controller.initialize();
    setState(() {});
    _controller.addListener(listener);
  }

  @override
  void dispose() {
    super.dispose();
    print('dispose: ${widget.source.id}');
    _controller.removeListener(listener);
    _controller?.pause();
    _controller?.dispose();
  }

  @override
  void didUpdateWidget(covariant DemoVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isFocus && !widget.isFocus) {
      // pause
      _controller?.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Hero(
                  tag: widget.source.id,
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
              _controller.value.isPlaying == true
                  ? SizedBox()
                  : IgnorePointer(
                      ignoring: true,
                      child: Icon(
                        Icons.play_arrow,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
            ],
          )
        : Theme(
            data: ThemeData(
                cupertinoOverrideTheme:
                    CupertinoThemeData(brightness: Brightness.dark)),
            child: CupertinoActivityIndicator(radius: 30));
  }
}
