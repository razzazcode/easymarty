import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/uploadItems.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/DialogBox/errorDialog.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Store/storehome.dart';
import 'package:e_shop/Config/config.dart';



class adminRegister extends StatefulWidget {
  @override
  _adminRegisterState createState() => _adminRegisterState();
}



class _adminRegisterState extends State<adminRegister> {
  final TextEditingController _adminnameTextEditingControler = TextEditingController();

  final TextEditingController _adminemailTextEditingControler = TextEditingController();
  final TextEditingController _adminpasswordTextEditingControler = TextEditingController();
  final TextEditingController _admincpasswordTextEditingControler = TextEditingController();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  String adminuserImageUrl = "";

 // File _adminimageFile;

  PickedFile imageofCamera , pickedimageGallery;
  File pickedimagewithpathAdmin ,  image2gallery;


  @override
  Widget build(BuildContext context) {
    double _screenwidth = MediaQuery
        .of(context)
        .size
        .width,
        _screenHeight = MediaQuery
            .of(context)
            .size
            .height;


    return SingleChildScrollView(

      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [


            SizedBox(height: 10.0,),


            InkWell(
              onTap:  _showMyDialog , // selectAndPickImage,
              child: CircleAvatar(

                radius: _screenwidth * 0.15,

                backgroundColor: Colors.white,
                backgroundImage: pickedimagewithpathAdmin == null ? null : FileImage(
                    pickedimagewithpathAdmin),

                child: pickedimagewithpathAdmin == null
                    ? Icon(Icons.add_photo_alternate, size: _screenwidth * 0.15,
                  color: Colors.grey,)

                    : null,

              ),
            ),


            SizedBox(height: 8.0,),
            Form(
              key: _formkey,
              child: Column(
                children: [
                  CustomTextField(

                    controller: _adminnameTextEditingControler,
                    data: Icons.person,
                    hintText: "Name",
                    isObsecure: false,
                  ),


                  CustomTextField(
//colorr: null,
                    controller: _adminemailTextEditingControler,
                    data: Icons.email,
                    hintText: "Email",
                    isObsecure: false,
                  ),

                  CustomTextField(

                    controller: _adminpasswordTextEditingControler,
                    data: Icons.lock,
                    hintText: "Password",
                    isObsecure: true,
                  ),

                  CustomTextField(

                    controller: _admincpasswordTextEditingControler,
                    data: Icons.local_activity,
                    hintText: "confirm password",
                    isObsecure: true,
                  ),


                ],
              ),
            ),

            RaisedButton(
              onPressed: () {
                uploadAndSaveImage();
              },

              color: Colors.pink,
              child: Text(" Sign Up", style: TextStyle(color: Colors.white),),
            ),


            SizedBox(
              height: 30.0,

            ),

            Container(
              height: 4.0,
              width: _screenwidth * 0.8,
              color: Colors.pink,
            ),

            SizedBox(
              height: 15.0,
            ),

          ],

        ),
      ),
    );
  }



  Future<void> captureAndPickImage() async {
    //  _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    imageofCamera =  await ImagePicker().getImage(
        source: ImageSource.camera
    );


    pickedimagewithpathAdmin = File(imageofCamera.path);

  }


  Future<void> galleryPickImage() async {
    //  _imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    pickedimageGallery =  await ImagePicker().getImage(
        source: ImageSource.gallery
    );


    pickedimagewithpathAdmin = File( pickedimageGallery.path);

  }


  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please select a profile picture.'),
                Text('Would you like to select from gallery or to Capture a new photo ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Camera'),
              onPressed: () {
                captureAndPickImage();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Gallery'),
              onPressed: () {

                Navigator.of(context).pop();

                //  _imageFile =  ImagePicker.pickImage(source: ImageSource.gallery) as File;
                galleryPickImage();
                Navigator.of(context).pop();

              },


            ),
          ],
        );
      },
    );
  }


/*
  Future<void> selectAndPickImage() async {
    _adminimageFile = await ImagePicker.pickImage(source: ImageSource.gallery, maxHeight: 600.0 , maxWidth: 970.0);
  }

*/
  Future<void> uploadAndSaveImage() async {
    if (pickedimagewithpathAdmin == null) {
      showDialog(
          context: context,
          builder: (c) {
            return ErrorAlertDialog(message: " Please select an Image",);
          }
      );
    }
    else { _adminpasswordTextEditingControler.text == _admincpasswordTextEditingControler.text
        ? _adminemailTextEditingControler.text.isNotEmpty && _adminpasswordTextEditingControler.text.isNotEmpty
        && _admincpasswordTextEditingControler.text.isNotEmpty && _adminnameTextEditingControler.text.isNotEmpty


        ? uploadToStorage()

        :

    displayDialog("pleasr write correct information")
        : displayDialog("Passwords do not match");

    }
  }

  displayDialog( String msg)
  {

    showDialog(
        context: context,

        builder: (c)
        {
          return ErrorAlertDialog(message: msg,);
        }
    );
  }






  uploadToStorage() async
  {

    showDialog(context: context ,
        builder: (c) {

          return LoadingAlertDialog( message: " Registering adminuser, Please WAIT",);
        }

    );

    String adminimageFileName = DateTime.now().millisecondsSinceEpoch.toString();


    StorageReference storageReference = FirebaseStorage.instance.ref().child(adminimageFileName);

    StorageUploadTask storageUploadTask = storageReference.putFile(pickedimagewithpathAdmin);


    StorageTaskSnapshot taskSnapshot = await storageUploadTask.onComplete;

    await taskSnapshot.ref.getDownloadURL().then((adminurlImage){
      adminuserImageUrl = adminurlImage ;

      _registeradminUser();



    } );


  }


  FirebaseAuth _auth = FirebaseAuth.instance;

  void _registeradminUser() async {

    FirebaseUser firebaseadminUser;

    await _auth.createUserWithEmailAndPassword
      (
      email: _adminemailTextEditingControler.text.trim(),

      password: _adminpasswordTextEditingControler.text.trim(),
    )

        .then((auth) {
      firebaseadminUser = auth.user;
    })

        .catchError((error){

      Navigator.pop(context);

      showDialog(
          context : context,

          builder: (c)
          {

            return ErrorAlertDialog(message: error.message.toString(),);
          }
      );


    });


    if(firebaseadminUser!= null) {
      saveadminUserInfoToFireStore(firebaseadminUser).then((value) {

        Navigator.pop(context);

        Route route = MaterialPageRoute(builder: (c) => UploadPage());

        Navigator.pushReplacement(context, route);


      });
    }
  }

  Future saveadminUserInfoToFireStore(FirebaseUser fadminUser) async
  {

    Firestore.instance.collection("users").document(fadminUser.uid).setData({

      "uid" : fadminUser.uid ,
      "email" : fadminUser.email,
      "name" : _adminnameTextEditingControler.text.trim(),
      "url" : adminuserImageUrl,
      "password" : _adminpasswordTextEditingControler.text.trim(),
      "userType": "admin",
      EcommerceApp.userCartoonList: ["garbagrValue"]

    });



    Firestore.instance.collection("admins").document(fadminUser.uid).setData({

      "uid" : fadminUser.uid ,
      "email" : fadminUser.email,
      "name" : _adminnameTextEditingControler.text.trim(),
      "url" : adminuserImageUrl,
      "password" : _adminpasswordTextEditingControler.text.trim(),
"userType": "admin",
      EcommerceApp.userCartoonList: ["garbagrValue"]

    });



    await EcommerceApp.sharedPreferences.setString("uid", fadminUser.uid);
    await EcommerceApp.sharedPreferences.setString("email", fadminUser.email);
    await EcommerceApp.sharedPreferences.setString( EcommerceApp.userName, _adminnameTextEditingControler.text.trim());
    await EcommerceApp.sharedPreferences.setString(EcommerceApp.userAvatarUrl, adminuserImageUrl);
    await EcommerceApp.sharedPreferences.setStringList(EcommerceApp.userCartoonList, ["garbageValue"]);
    await EcommerceApp.sharedPreferences.setString( EcommerceApp.passWord, _adminpasswordTextEditingControler.text.trim());
    await EcommerceApp.sharedPreferences.setString( EcommerceApp.userType, "admin");

  }
}



