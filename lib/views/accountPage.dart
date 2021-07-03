import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyapp/config/config.dart';
import 'package:wallyapp/views/addImageDialogue.dart';
import 'package:wallyapp/views/wallpaper_view_screen.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  User _user;

  @override
  void initState() {
    // TODO: implement initState
    fetchUserData();
    super.initState();
  }

  void fetchUserData() async {
    User u = await _auth.currentUser;
    setState(() {
      _user = u;
    });
  }

  var images = [
    "https://images.pexels.com/photos/775483/pexels-photo-775483.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/3326103/pexels-photo-3326103.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
    "https://images.pexels.com/photos/1927314/pexels-photo-1927314.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
    "https://images.pexels.com/photos/2085376/pexels-photo-2085376.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/3377538/pexels-photo-3377538.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/3381028/pexels-photo-3381028.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940",
    "https://images.pexels.com/photos/3389722/pexels-photo-3389722.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940"
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: _user != null
            ? Column(
                children: <Widget>[
                  SizedBox(
                    height: 20,
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      height: 200,
                      width: 200,
                      imageUrl: _user.photoURL,
                      placeholder: (ctx, url) => Image(
                          fit: BoxFit.cover,
                          image: AssetImage("assets/placeholder.jpg")),
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "${_user.displayName}",
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextButton(
                    onPressed: () {
                      _auth.signOut();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 10.0),
                      child: Text(
                        "Sign Out",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      primary: Colors.grey[200],
                      backgroundColor: primaryColor,
                      onSurface: Colors.grey,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                      alignment: Alignment.topLeft,
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "My Collection",
                            style: TextStyle(color: Colors.grey, fontSize: 20),
                            textAlign: TextAlign.start,
                          ),
                          IconButton(
                            icon: Icon(Icons.add_a_photo),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (conext) => AddImageScreen(),
                                      fullscreenDialog: true));
                            },
                            color: Colors.grey,
                          )
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  StreamBuilder(
                    stream: _db
                        .collection("Wallpapers")
                        .orderBy("date", descending: true)
                        .snapshots(),
                    builder: (ctx, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data.docs.isNotEmpty) {
                          return StaggeredGridView.countBuilder(
                            scrollDirection: Axis.vertical,
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            itemCount: snapshot.data.docs.length,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            itemBuilder: (context, index) {
                              //print(data);
                              return Container(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                wallpaperViewScreen(
                                                  data:
                                                      snapshot.data.docs[index],
                                                )));
                                  },
                                  child: Stack(
                                    children: [
                                      Hero(
                                        tag: snapshot.data.docs[index]
                                            .get("url"),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: CachedNetworkImage(
                                            imageUrl: snapshot.data.docs[index]
                                                .get("url"),
                                            placeholder: (ctx, url) => Image(
                                                fit: BoxFit.cover,
                                                image: AssetImage(
                                                    "assets/placeholder.jpg")),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (ctx) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16)),
                                                    title: Text("Confimation"),
                                                    content: Text(
                                                        "Do you want to delete this wallpaper?"),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx)
                                                              .pop();
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 8.0,
                                                                  horizontal:
                                                                      10.0),
                                                          child: Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                                fontSize: 15),
                                                          ),
                                                        ),
                                                        style: TextButton
                                                            .styleFrom(
                                                          primary:
                                                              Colors.grey[200],
                                                          backgroundColor:
                                                              primaryColor,
                                                          onSurface:
                                                              Colors.grey,
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          _db
                                                              .collection(
                                                                  "Wallpapers")
                                                              .doc(snapshot
                                                                  .data
                                                                  .docs[index]
                                                                  .id)
                                                              .delete();

                                                          Navigator.of(ctx)
                                                              .pop();
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 8.0,
                                                                  horizontal:
                                                                      10.0),
                                                          child: Text(
                                                            "Delete",
                                                            style: TextStyle(
                                                                fontSize: 15),
                                                          ),
                                                        ),
                                                        style: TextButton
                                                            .styleFrom(
                                                          primary:
                                                              Colors.grey[200],
                                                          backgroundColor:
                                                              primaryColor,
                                                          onSurface:
                                                              Colors.grey,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                });
                                          }),
                                    ],
                                  ),
                                ),
                              );
                            },
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20.0,
                            staggeredTileBuilder: (int index) =>
                                StaggeredTile.fit(1),
                          );
                        } else {
                          return SpinKitPulse(
                            color: primaryColor,
                            size: 50,
                          );
                        }
                      }
                      return SpinKitPulse(
                        color: primaryColor,
                        size: 50,
                      );
                    },
                  ),
                ],
              )
            : LinearProgressIndicator(),
      ),
    );
  }
}
