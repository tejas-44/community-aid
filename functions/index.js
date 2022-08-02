const functions = require("firebase-functions");
const admin =  require('firebase-admin');
admin.initializeApp();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreatePost = functions.firestore
    .document("/posts/{userId}/userPosts/{postId}/")
    .onCreatePost(async (snapshot,context)=> {
        console.log('Idk',snapshot.data())
        const userId = context.params.userId;
        const postId = context.params.postId;

        const userPostsRef = admin
        .firestore()
        .collection('posts')
        .doc(userId)
        .collection('userPosts');

        const timelinePostsRef = admin
        .firestore()
        .collection('timeline')
        .doc(userId)
        .collection('timelinePosts');

         cons querySnapshot = await userPostsRef.get();

         querySnapshot.forEach(doc => {
         if(doc.exists){
         postId = doc.id;
         const postData doc.data;
         timelinePostsRef.doc(postId).set(postData);
         }
         })



    });

