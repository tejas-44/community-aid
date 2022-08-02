import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/pages/create_account.dart';
import 'package:fluttershare/pages/profile.dart';
import 'package:fluttershare/pages/timeline.dart';
import 'package:fluttershare/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageRef = FirebaseStorage.instance.ref();
final commentsRef = Firestore.instance.collection('comments');
final usersRef = Firestore.instance.collection('users');
final postsRef = Firestore.instance.collection('posts');
final timelineRef = Firestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      handleSigninAccount(account);
    }, onError: (err) {
      print('Error signing in : $err');
    });
    googleSignIn.signInSilently(suppressErrors: false).then((account) {
      handleSigninAccount(account);
    }).catchError((err) {
      print('Error signing in: $err');
    });

  }



  handleSigninAccount(GoogleSignInAccount account) async {
    if (account != null) {
      await createUserInFirestore();
      setState(() {
        isAuth = true;
      });
    } else
      setState(() {
        isAuth = false;
      });
  }

  createUserInFirestore() async {
    final GoogleSignInAccount user = googleSignIn.currentUser;
     DocumentSnapshot doc = await usersRef.document(user.id).get();

    if (!doc.exists) {
    final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));

    usersRef.document(user.id).setData({
      "id": user.id,
      "username" : username,
      "photoUrl" : user.photoUrl,
      "email" : user.email,
      "displayName" : user.displayName,
      "bio" : "",
      "timestamp" : timestamp,
    });

    doc = await usersRef.document(user.id).get();
    }
     currentUser =  User.fromDocument(doc);
    if  (currentUser.username == null) {
      final username = await Navigator.push(
          context, MaterialPageRoute(builder: (context) => CreateAccount()));
      usersRef.document(user.id).updateData({
        "username" : username,
      });
    }
    print(currentUser);
    print(currentUser.displayName);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  login() {
    googleSignIn.signIn();
  }



  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(pageIndex,
        duration: Duration(milliseconds: 400), curve: Curves.fastLinearToSlowEaseIn);
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
      body: PageView(
        children: <Widget>[
          Timeline(currentUser : currentUser),
          Upload(currentUser : currentUser),
          Profile(profileId : currentUser?.id),
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CupertinoTabBar(

        backgroundColor: Colors.grey,
        inactiveColor: Colors.white,
        currentIndex: pageIndex,
        onTap: onTap,
        activeColor: Theme.of(context).accentColor,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(
              icon: Center(
                child: Icon(
            Icons.photo_camera,
          ),
              )),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle))
        ],
      ),
    );
    // return RaisedButton(
    //   child: Text('Logout'),
    //   onPressed: logout,
    // );
  }

  buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
            ])),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo.png',
              width: MediaQuery. of(context). size. width,
              height: MediaQuery. of(context). size. width,
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260,
                height: 60,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/images/google_signin_button.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
