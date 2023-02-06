import 'dart:io';
import 'package:auth/AuthScreen/SignIn.dart';
import 'package:auth/AuthScreen/homeScreen.dart';
import 'package:auth/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;
  final TextEditingController _username = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final formkey = GlobalKey<FormState>();
  String? selectedValue;
  String? selectedYear;
  String? passoutYear;
  bool visible = false;
  List yearList = [];
  String? _value1;
  PlatformFile? file1;
   var pdfURL;
   var imageURL;
  File? image;
  var filePath;
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("Student"), value: "Student"),
      const DropdownMenuItem(child: Text("Alumni"), value: "Alumni")
    ];
    return menuItems;
  }
  List<DropdownMenuItem<String>> get admissionDropMenu {
    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("2019"), value: "2019"),
      const DropdownMenuItem(child: Text("2020"), value: "2020"),
      const DropdownMenuItem(child: Text("2021"), value: "2021"),
      const DropdownMenuItem(child: Text("2022"), value: "2022")
    ];
    return menuItems;
  }
  final ImagePicker picker = ImagePicker();
  Future getImage() async {
    var img = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = File(img!.path);
    });
  }
  Future getResumePdf() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null) {
      print("result none");
      return;
    }
    setState(() {
      file1 = result.files.first;
    });
    print(file1!.path);
  }
  AuthClass authClass = AuthClass();
  void signupWhenValidate() async {
    if(image == null){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload the image')));
      return;
    }
    if(file1 == null){
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload the pdf')));
      return;
    }
    if (formkey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      String? year="";
      if(selectedYear != null){
        year=selectedYear;
      }else{
        year = _value1;
      }
     if(year != null && selectedValue != null ){
       await authClass
           .signUpwithEmail(
           _email.text, _password.text, context, _username.text)
           .then((value) async{
         Reference referenceRoot =FirebaseStorage.instance.ref();
         Reference directoryPdf =referenceRoot.child('pdf');
         Reference imagePdf =referenceRoot.child('images');
         Reference imageToUpload = imagePdf.child("image"+DateTime.now().millisecondsSinceEpoch.toString());
         Reference pdfToUpload = directoryPdf.child("${file1?.name}"+DateTime.now().millisecondsSinceEpoch.toString());
         try{
           await imageToUpload.putFile(File(image!.path));
           await pdfToUpload.putFile(File(file1!.path!));
           imageURL = await imageToUpload.getDownloadURL();
           pdfURL =await pdfToUpload.getDownloadURL();
         if(year != null){
           Map<String, String> info = {
             'email': _email.text,
             'name': _username.text,
             'phone': _phone.text,
             'imageURL':imageURL,
             'pdfURL':pdfURL,
             'userType':selectedValue!,
             'year':year
           };
           await FirebaseFirestore.instance.collection('users').add(info);
         }
         }
         catch(error){
           ScaffoldMessenger.of(context)
               .showSnackBar(SnackBar(content: Text(error.toString())));
         }
         Navigator.of(context).pushAndRemoveUntil(
             MaterialPageRoute(
                 builder: (context) => const HomeScreen()),
                 (Route<dynamic> route) => false);
       });
     }
    }
  }
  @override
  void initState() {
    for (int i = 1990; i <= 2020; i++) {
      yearList.add(i.toString());
    }
    _value1 = yearList[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: formkey,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DropdownButtonFormField(
                          decoration: InputDecoration(
                            hintText: "Choose Type",
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black54, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            border: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Colors.black54, width: 2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            fillColor: Colors.white,
                          ),
                          validator: (value) => value == null
                              ? "Please fill the required field"
                              : null,
                          dropdownColor: Colors.white,
                          value: selectedValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedValue = newValue!;
                              visible = true;
                            });
                          },
                          items: dropdownItems),
                      TextFormField(
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "Name can't be empty";
                          }
                          return null;
                        },
                        controller: _username,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                        ),
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value != null && value.isEmpty) {
                            return "email can't be empty";
                          }
                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value!)) {
                            return "Please enter a valid email address";
                          }
                          return null;
                        },
                        controller: _email,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                        ),
                      ),
                      TextFormField(
                        validator: (String? value) {
                          if (value != null && value.isEmpty) {
                            return "phone number can't be empty";
                          }

                          return null;
                        },
                        controller: _phone,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                        ),
                      ),
                      TextFormField(
                        validator: (String? value) {
                          if (value != null && value.isEmpty) {
                            return "password can't be empty";
                          }
                          if (value != null && value.length <= 6) {
                            return "password length must be greater than equal to six";
                          }
                          return null;
                        },
                        controller: _password,
                        obscureText: true,
                        decoration: const InputDecoration(hintText: 'Password'),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          image != null
                              ? Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: CircleAvatar(
                                    radius: 50,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        image!,
                                        fit: BoxFit.cover,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 100,
                                      ),
                                    ),
                                  ),
                                )
                              : const Text(
                                  "No Image Selected :",
                                  style: TextStyle(color: Colors.red),
                                ),
                          GestureDetector(
                            onTap: () {
                              getImage();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 10),
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.black)),
                              child: const Text("Upload Profile pic"),
                            ),
                          )
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: GestureDetector(
                          onTap: () {
                            getResumePdf();
                          },
                          child: Row(
                            children: [
                              const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: Colors.red,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              file1 != null
                                  ? Flexible(flex:1,child: Text(file1!.name))
                                  : const Text(
                                      "Upload Your resume",
                                      style: TextStyle(color: Colors.red),
                                    ),
                              file1 != null ? Flexible(flex:2,child: Text(file1!.size.toString())): const SizedBox()
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: visible,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              selectedValue == "Student"
                                  ? const Text(
                                      'Admission Year',
                                      style: TextStyle(fontSize: 18),
                                    )
                                  : const Text(
                                      'Pass-out Year',
                                      style: TextStyle(fontSize: 18),
                                    ),
                              const SizedBox(
                                width: 8,
                              ),
                              selectedValue == "Student"
                                  ? Flexible(
                                      child: DropdownButtonFormField(
                                          decoration: InputDecoration(
                                            hintText: "Choose Year",
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black54,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black54,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            fillColor: Colors.white,
                                          ),
                                          validator: (value) => value == null
                                              ? "Please fill the required field"
                                              : null,
                                          dropdownColor: Colors.white,
                                          value: selectedYear,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              selectedYear = newValue!;
                                            });
                                          },
                                          items: admissionDropMenu),
                                    )
                                  : Flexible(
                                      child: DropdownButton<String>(
                                        value: _value1,
                                        style: const TextStyle(
                                            color: Colors.black, fontSize: 15),
                                        items: yearList
                                            .map<DropdownMenuItem<String>>(
                                                (value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style:
                                                  const TextStyle(fontSize: 30),
                                            ),
                                          );
                                        }).toList(),
                                        // Step 5.
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _value1 = newValue!;
                                          });
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          signupWhenValidate();
                        },
                        child: Container(
                          width: size.width,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text('Already have an account?'),
                          const SizedBox(
                            width: 3,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const SignIn()),
                                  (Route<dynamic> route) => false);
                            },
                            child: const Text(
                              'SignIn Here',
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
