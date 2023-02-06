import 'package:auth/AuthScreen/SignIn.dart';
import 'package:auth/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  AuthClass signOut = AuthClass();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Registered Users'),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () {
                setState(() {
                  _isLoading = true;
                });
                signOut.signOut(context).then((value) =>  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const SignIn()),
                        (Route<dynamic> route) => false));
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasData) {
                    return ListView.builder(
                      itemBuilder: (context, index) {
                        if (!snapshot.hasData) {
                          return const Text('not registered user yet');
                        }
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 55.0,
                                backgroundImage: NetworkImage(
                                    snapshot.data?.docs[index]['imageURL']),
                                backgroundColor: Colors.transparent,
                              ),
                              const SizedBox(width: 10,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Name: ${snapshot.data?.docs[index]['name']}",style: const TextStyle(fontSize: 18),),
                                  const SizedBox(width: 6,),
                                  Text("Email: ${snapshot.data?.docs[index]['email']}",style: const TextStyle(fontSize: 18),),
                                  const SizedBox(width: 8,),
                                  Text("Phone No.: ${snapshot.data?.docs[index]['phone']}",style: const TextStyle(fontSize: 15,fontWeight: FontWeight.w500
                                  ),),
                                  const SizedBox(width: 6,),
                                  Text("User Type: ${snapshot.data?.docs[index]['userType']}",style: const TextStyle(fontSize: 18,),),
                                  const SizedBox(width: 5,),
                                  Text("Year: ${snapshot.data?.docs[index]['year']}",style: const TextStyle(fontSize: 18),),
                                  const SizedBox(width: 6,),
                                  // GestureDetector(
                                  //   onTap:(){
                                  //     print("url:${snapshot.data?.docs[index]['pdfURL']}");
                                  //     var uri =Uri.parse(snapshot.data?.docs[index]['pdfURL']);
                                  //     canLaunchUrl(uri);
                                  //   },
                                  //   child: Row(
                                  //     children: const [
                                  //      Text("Resume:",style: TextStyle(fontSize: 18),),
                                  //      SizedBox(width: 10,),
                                  //       Icon(Icons.picture_as_pdf,color: Colors.red,)
                                  //     ],
                                  //   ),
                                  // ),
                                ],
                              )
                            ],
                          ),
                        );
                      },
                      itemCount: snapshot.data?.docs.length,
                    );
                  }
                  return const Center(
                      child: Text(
                    ' The user is not register yet',
                    style: TextStyle(color: Colors.white, fontSize: 19),
                  ));
                },
              ));
  }
}
// LaunchURL(String url)async {
//   if (canLaunch(url) != null) {
//     await launch(url);
//   } else {
//     print('Can\'t launch ${url}');
//   }
// }
