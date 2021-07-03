import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:share/share.dart';
import 'package:wallyapp/config/config.dart';

class wallpaperViewScreen extends StatefulWidget {
  final DocumentSnapshot data;
  wallpaperViewScreen({this.data});
  @override
  _wallpaperViewScreenState createState() => _wallpaperViewScreenState();
}

class _wallpaperViewScreenState extends State<wallpaperViewScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool isFavorite = false;
  User user;
  @override
  void initState() {
    // TODO: implement initState
    _getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Container(
                child: Hero(
                  tag: widget.data.get("url"),
                  child: CachedNetworkImage(
                    placeholder: (ctx, url) =>
                        Image(image: AssetImage("assets/placeholder.jpg")),
                    imageUrl: widget.data.get("url"),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Wrap(direction: Axis.horizontal, spacing: 10, children: <Widget>[
                for (int i = 0; i < widget.data.get("tags").length; i++)
                  _listItem(widget.data.get("tags")[i])
              ]),
              SizedBox(
                height: 10,
              ),
              Wrap(
                direction: Axis.horizontal,
                spacing: 10,
                children: <Widget>[
                  TextButton.icon(
                    onPressed: () {
                      _launchUrl();
                    },
                    icon: Icon(Icons.download_rounded),
                    label: Text("Get Wallpaper"),
                    style: TextButton.styleFrom(
                      primary: Colors.grey[200],
                      backgroundColor: primaryColor,
                      onSurface: Colors.grey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      createDynamicLink();
                    },
                    icon: Icon(Icons.share),
                    label: Text("Share"),
                    style: TextButton.styleFrom(
                      primary: Colors.grey[200],
                      backgroundColor: primaryColor,
                      onSurface: Colors.grey,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _addFavorite();
                    },
                    icon: Icon(!isFavorite
                        ? Icons.favorite_border_outlined
                        : Icons.favorite),
                    label: Text("Favorite"),
                    style: TextButton.styleFrom(
                      primary: Colors.grey[200],
                      backgroundColor: primaryColor,
                      onSurface: Colors.grey,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _listItem(String label) {
    return Chip(label: Text(label));
  }

  void _launchUrl() async {
    try {
      await launch(widget.data.get("url"),
          customTabsOption: CustomTabsOption(
            toolbarColor: Theme.of(context).primaryColor,
          ));
    } catch (e) {
      print(e.toString());
    }
  }

  void _getUser() async {
    User u = _auth.currentUser;
    bool fav = false;
    await _db
        .collection("users")
        .doc(u.uid.toString())
        .collection("favorites")
        .doc(widget.data.id)
        .get()
        .then((value) => {
              if (value.exists) {fav = true} else {fav = false}
            });
    setState(() {
      user = u;
      isFavorite = fav;
    });
  }

  void _addFavorite() {
    if (isFavorite) {
      _db
          .collection("users")
          .doc(user.uid.toString())
          .collection("favorites")
          .doc(widget.data.id)
          .delete();
    } else {
      _db
          .collection("users")
          .doc(user.uid.toString())
          .collection("favorites")
          .doc(widget.data.id)
          .set(widget.data.data());
    }
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void createDynamicLink() async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
        uriPrefix: "http://wallyapp2542.page.link",
        link: Uri.parse(widget.data.get("url").toString()),
        androidParameters: AndroidParameters(
            packageName: "com.wallyapp.App", minimumVersion: 0),
        iosParameters:
            IosParameters(bundleId: "com.wallyapp.App", minimumVersion: "0"),
        socialMetaTagParameters: SocialMetaTagParameters(
            title: "WallyApp",
            description: "A wallpaper sharing app",
            imageUrl: Uri.parse(widget.data.get("url"))));

    Uri uri = await parameters.buildUrl();

    String url = uri.toString();
    print(url);
    Share.share(url);
  }
}
