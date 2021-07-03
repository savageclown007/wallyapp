
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wallyapp/config/config.dart';
import 'package:path/path.dart' as path;

class AddImageScreen extends StatefulWidget {
  @override
  _AddImageScreenState createState() => _AddImageScreenState();
}

class _AddImageScreenState extends State<AddImageScreen> {
  PickedFile _image;
  final _picker = ImagePicker();
  final imageLabeler = GoogleMlKit.vision.imageLabeler();
  List<ImageLabel> detectedLabels;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool uploading = false;
  bool uploadComplete = false;

  var tags = [];

  @override
  void dispose() {
    imageLabeler.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add image"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              InkWell(
                onTap: () {
                  _loadImage();
                },
                child: _image != null
                    ? Image.file(File(_image.path))
                    : Image(image: AssetImage("assets/placeholder.jpg")),
              ),
              SizedBox(
                height: 10,
              ),
              detectedLabels != null
                  ? Wrap(
                      direction: Axis.horizontal,
                      spacing: 10,
                      children: <Widget>[
                          for (int i = 0; i < detectedLabels.length; i++)
                            _listItem(detectedLabels[i].label)
                        ])
                  : Container(),
              SizedBox(
                height: 15,
              ),

              if(uploading)...[
                Text("Wallpaper is uploading...")
              ],

              if(uploadComplete)...[
                Text("Uploaded Successfully")
              ],
              _image == null
                  ? Text(
                      "Tap on image to add wallaper",
                      style: TextStyle(color: Colors.grey, fontSize: 25),
                    )
                  : Container(
                      child: TextButton(
                      onPressed: () {
                        _uploadWallpaper();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 10.0),
                        child: Text(
                          "Upload Imge",
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        primary: Colors.grey[200],
                        backgroundColor: primaryColor,
                        onSurface: Colors.grey,
                      ),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  void _loadImage() async {
    var image =
        await _picker.getImage(source: ImageSource.gallery, imageQuality: 30);
    if (image != null) {
      final InputImage inputImage = InputImage.fromFilePath(image.path);
      List<ImageLabel> labels = await imageLabeler.processImage(inputImage);

      for (var label in labels) {
        tags.add(label.label);
      }
      setState(() {
        detectedLabels = labels;
        _image = image;
      });
    }
  }

  Widget _listItem(String label) {
    return Chip(label: Text(label));
  }

  void _uploadWallpaper() async {
    String fileName = path.basename(_image.path);

    User user = _auth.currentUser;
    String uid = user.uid.toString();

    UploadTask task = _storage
        .ref("Wallpapers")
        .child(uid)
        .child(fileName)
        .putFile(File(_image.path));

    task.snapshotEvents.listen((event) {
      if (event.state == TaskState.running) {
        setState(() {
          uploading = true;
        });
      }
      if (event.state == TaskState.success) {
        setState(() {
          uploadComplete = true;
          uploading = false;
        });

        event.ref.getDownloadURL().then((url) => {
              _db.collection("Wallpapers").add({
                "url": url.toString(),
                "date": DateTime.now(),
                "uploaded_by": uid,
                "tags": tags
              }),
              Navigator.of(context).pop(),
            });
      }
    });
  }
}
