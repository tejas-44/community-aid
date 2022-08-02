import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:fluttershare/widgets/header.dart';
import 'package:fluttershare/widgets/post.dart';
import 'package:fluttershare/widgets/post_tile.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'edit_profile.dart';

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  String postOrientation = "grid";
  bool isLoading = false;
  int postCount = 0;
  List<Post> posts = [];

  @override
  void initState() {
    super.initState();
    getProfilePosts();
    pageRefresh();
  }

  pageRefresh() {
    buildProfileHeader();
    buildProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  Column buildCountColumn(String label, int count) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }

  Container buildButton({String text, Function function}) {
    return Container(
      padding: EdgeInsets.only(top: 2.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: MediaQuery.of(context).size.width/4,
          height: MediaQuery.of(context).size.height/22,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).accentColor,
            border: Border.all(color: Theme.of(context).accentColor),
            borderRadius: BorderRadius.circular(5.0),
          ),
        ),
      ),
    );
  }



  editProfile() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditProfile(currentUserId: currentUserId)));
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if(isProfileOwner){
      return buildButton(text: "Edit Profile", function: editProfile);
    }
    else return Text("");
  }

  logout() {
    googleSignIn.signOut();
  }
  handleLogout(BuildContext parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text("Log out of this app"),
            children: <Widget>[
              SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    logout();

                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(color: Colors.red),
                  )),
              SimpleDialogOption(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel')),
            ],
          );
        });
  }

  buildLogoutButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if(isProfileOwner){
      return buildButton(text: "Logout", function: logout);
    }
    else return Text("");
  }

  setPostsOrientation(String postOrientation){
    setState(() {
      this.postOrientation = postOrientation;
    });

  }

  buildProfilePosts() {
    if (isLoading) {
      return Center(child: circularProgress());
    } else if (posts.isEmpty) {
      return Container(
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
      );
    }
    else if (postOrientation == 'grid'){
      List<GridTile> gridTiles = [];
      posts.forEach((post) {
        gridTiles.add(GridTile(child: PostTile(post)));
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTiles,
      );
    } else if(postOrientation == 'list'){
      return Column(
        children: posts,
      );
    }


  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return linearProgress();
        }

        User user = User.fromDocument(snapshot.data);

        return Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.centerLeft,
                                      padding: EdgeInsets.only(top: 6),
                                      child: Text(
                                        user.username,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(top: 4),
                                      child: Text(
                                        'username',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w400),
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  width: 65,
                                ),
                                buildCountColumn("posts", postCount),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            buildProfileButton(),
                            buildLogoutButton(),

                          ],
                        ),

                      ],
                    ),
                    flex: 1,
                  ),
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 4),
                child: Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 2),
                child: Text(
                  user.bio,
                ),
              )
            ],
          ),
        );
      },
    );
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.grid_on),
          onPressed: ()=> setPostsOrientation("grid"),
          color: postOrientation == 'grid' ? Theme.of(context).primaryColor : Colors.grey,
        ),
        Divider(),
        IconButton(
          icon: Icon(Icons.list,size: 32,),
          onPressed: ()=> setPostsOrientation("list"),
          color: postOrientation == 'list' ? Theme.of(context).primaryColor : Colors.grey,
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Profile'),
      body: ListView(
            children: <Widget>[
              buildProfileHeader(),
              buildTogglePostOrientation(),
              Divider(),
              buildProfilePosts(),
            ],
          ),
    );
  }
}

showProfile(BuildContext context, {String profileId}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
      ),
    ),
  );
}
