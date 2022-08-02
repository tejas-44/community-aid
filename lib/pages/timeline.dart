
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'home.dart';

final usersRef = Firestore.instance.collection('users');

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});

  @override
  _TimelineState createState() => _TimelineState();

}

class _TimelineState extends State<Timeline> {

  List<Post> posts = [];

  @override
  void initState() {
      getTimeline();
      super.initState();
  }



  getTimeline() async {
    QuerySnapshot snapshot = await timelineRef
        .orderBy('timestamp', descending: true)
        .getDocuments();
    List<Post> posts =
    snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    setState(() {
      this.posts = posts;
    });
  }

  buildTimeline() {
    if (posts == null) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5),
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SvgPicture.asset('assets/images/no_content.svg', height: 260.0),
              Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Text(
                  "No Posts",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 40.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return ListView(children: posts);
    }
  }


  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(context, isAppTitle: true,),
      body: RefreshIndicator(child: buildTimeline(), onRefresh: () => getTimeline()),
    );
  }
}
