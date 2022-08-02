import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttershare/pages/home.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Im ;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttershare/models/user.dart';
import 'package:fluttershare/widgets/progress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});

  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> with AutomaticKeepAliveClientMixin<Upload> {
 TextEditingController locationController = TextEditingController();
 TextEditingController captionController = TextEditingController();
 File file;
  bool isUploading= false;
  String postId = Uuid().v4();

  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 960, maxHeight: 675);
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            title: Text('Create Post'),
            children: <Widget>[
              SimpleDialogOption(
                child: Text('Photo With Camera'),
                onPressed: handleTakePhoto,
              ),
              SimpleDialogOption(
                child: Text('Image From Gallery'),
                onPressed: handleChooseFromGallery,
              ),
              SimpleDialogOption(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        });
  }

  Container buildSplashScreen() {
    return Container(
      color: Theme.of(context).primaryColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: RaisedButton(
              color: Colors.deepOrange,
              onPressed: () {
                selectImage(context);
              },
              child: Text(
                'Upload Image',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  clearImage() {
    setState(() {
      file = null;
    });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')..writeAsBytesSync(Im.encodeJpg(imageFile,quality: 25));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
      StorageUploadTask uploadTask = storageRef.child("post_$postId.jpg").putFile(imageFile);
    StorageTaskSnapshot storageSnap =  await uploadTask.onComplete;
   String downloadUrl =  await storageSnap.ref.getDownloadURL();
   return downloadUrl;
  }

  createPostInFirestore({String mediaUrl, String location, String description}){
    postsRef
    .document(widget.currentUser.id)
        .collection('userPosts')
        .document(postId)
        .setData({
        "postId" : postId,
        "ownerId" : widget.currentUser.id,
      "username" : widget.currentUser.username,
      "mediaUrl" : mediaUrl,
      "description" : description,
      "location" : location,
      "timestamp" : timestamp,
      "likes" : {},
    });
  }

 createPostInFirestoreTimeline({String mediaUrl, String location, String description}){
   timelineRef
       .document(postId)
       .setData({
     "postId" : postId,
     "ownerId" : widget.currentUser.id,
     "username" : widget.currentUser.username,
     "mediaUrl" : mediaUrl,
     "description" : description,
     "location" : location,
     "timestamp" : timestamp,
     "likes" : {},
   });
 }



 handleSubmit()async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(mediaUrl: mediaUrl, location: locationController.text,description: captionController.text,);
    createPostInFirestoreTimeline(mediaUrl: mediaUrl,location: locationController.text,description: captionController.text);
    captionController.clear();
    locationController.clear();

    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }



  Scaffold buildUploadForm() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white70,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: clearImage,
        ),
        title: Center(
          child: Text(
            'Add Information',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          FlatButton(
            onPressed: isUploading ? null : () => handleSubmit(),
            child: Text(
              "Post",
              style: TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0),
            ),
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress( ) : Text(''),
          Container(
            height: 220,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                    fit: BoxFit.cover,
                    image: FileImage(file),
                  )),
                ),
              ),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: 10)),
          ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write A Description...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Divider(),
          ListTile(
            leading: Icon(
              Icons.pin_drop,
              color: Colors.orange,
              size: 35,
            ),
            title: Container(
              width: 250,
              child: TextField(
                controller: locationController,
                decoration: InputDecoration(
                    hintText: "Where was this photo taken?",
                    border: InputBorder.none),
              ),
            ),
          ),
          Container(
            width: 200,
            height: 100,
            alignment: Alignment.center,
            child: RaisedButton.icon(
                onPressed: ()=> getUserLocation(),
                icon: Icon(Icons.my_location, color: Colors.white,),
                label: Text(
                  'Use Current Location',
                  style: TextStyle(color: Colors.white),
                ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

 getUserLocation() async {
   Position position =  await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
  List<Placemark> placemarks =  await Geolocator().placemarkFromCoordinates(position.latitude, position.longitude);
  Placemark placemark= placemarks[0];
  String formattedAddress = "${placemark.subLocality},${placemark.subAdministrativeArea}";

  locationController.text = formattedAddress;
 }


  bool get wantKeepAlive => true;

  @override

  Widget build(BuildContext context) {
    super.build(context);
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}
