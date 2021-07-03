import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:wallyapp/config/config.dart';
import 'package:wallyapp/views/wallpaper_view_screen.dart';

class ExplorePage extends StatefulWidget {
  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(top: 5, left: 20, bottom: 20),
              child: Text(
                "Explore",
                textAlign: TextAlign.start,
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
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
                                      builder: (context) => wallpaperViewScreen(
                                            data: snapshot.data.docs[index],
                                          )));
                            },
                            child: Hero(
                              tag: snapshot.data.docs[index].get("url"),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      snapshot.data.docs[index].get("url"),
                                  placeholder: (ctx, url) => Image(
                                      fit: BoxFit.cover,
                                      image:
                                          AssetImage("assets/placeholder.jpg")),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20.0,
                      staggeredTileBuilder: (int index) {
                        return StaggeredTile.count(1, index.isEven ? 1.2 : 1.8);
                      },
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
        ),
      ),
    );
  }
}
