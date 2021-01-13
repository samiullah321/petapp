import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Admin/adminShiftOrders.dart';
import 'package:e_shop/DialogBox/loadingDialog.dart';
import 'package:e_shop/Models/item.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Widgets/customTextField.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:e_shop/Widgets/searchBox.dart';
import 'package:e_shop/main.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as ImD;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Config/config.dart';
import 'package:e_shop/Store/storehome.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

GeoPoint loc;

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  startSearching() {
    setState(() {
      print(1);
    });
  }

  final GlobalKey<FormFieldState> _breedFormKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _categoryFormKey =
  GlobalKey<FormFieldState>();

  final GlobalKey<FormFieldState> _ageFormKey = GlobalKey<FormFieldState>();

  final GlobalKey<FormFieldState> _locationFormKey =
  GlobalKey<FormFieldState>();

  final GlobalKey<FormFieldState> _phoneFormKey = GlobalKey<FormFieldState>();
  final GlobalKey<FormFieldState> _weightFormKey = GlobalKey<FormFieldState>();

  bool _isSubmitButtonEnabled = false;
  FocusNode myFocusNode;

  bool get wantKeepAlive => true;

  /*File file;*/
  File _image1;
  File _image2;
  File _image3;
  String distance = "Loading";
  double tlat;
  double tlong;

  var tempModel = new ItemModel();
  var ctime;
  TextEditingController _infotextEditingController = TextEditingController();
  TextEditingController _breedtextEditingController = TextEditingController();
  TextEditingController _weighttextEditingController = TextEditingController();
  TextEditingController _colortextEditingController = TextEditingController();
  TextEditingController _agetextEditingController = TextEditingController();
  TextEditingController _searchtextEditingController = TextEditingController();
  TextEditingController _locationtextEditingController =
  TextEditingController();
  TextEditingController _phonetextEditingController = TextEditingController();
  TextEditingController _categorytextEditingController =
  TextEditingController();
  String uidcontroller;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();
  bool uploading = false;
  String display = "home";
  bool onedit = false;

  Completer<GoogleMapController> _controller = Completer();

  LatLng _center = new LatLng(1, 1);

  LatLng temp;

  MapType _currentMapType = MapType.normal;

  initState() {
    super.initState();
  }

  @override
  @override
  Widget build(BuildContext context) {
    if(loc==null)
    {
      getloc();
    }

    if (display == "home") {
      onedit = false;
      return displayAdminHomescreen();
    } else if (display == "post") {
      onedit = false;
      return displayAdminUploadFormScreen();
    } else if (display == "edit") {
      onedit = true;
      return editFormScreen();
    } else if (display == "loc") {
      return locationpage();
    }


  }

  displayAdminHomescreen() {
    return WillPopScope(
      onWillPop: () {
        Route route = MaterialPageRoute(builder: (c) => StoreHome());
        Navigator.pushReplacement(context, route);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          bottom: PreferredSize(
            child: searchWidget(),
            preferredSize: Size(56.0, 56.0),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () => setDisplay("post"),
            ),
          ],
          flexibleSpace: Container(
            alignment: Alignment.center,
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xfffbb448), Color(0xfff7892b)]),
            ),
          ),
          title: Image.asset(
            "images/1.png",
            width: 250,
          ),
          centerTitle: true,
        ),
        drawer: MyDrawer(),
        body: getAdminHomeScreenBody(),
      ),
    );
  }

  getAdminHomeScreenBody() {
    return Container(
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(pinned: true, delegate: SearchBoxDelegate()),
          StreamBuilder<QuerySnapshot>(
              stream: petadoptapp.firestore
                  .collection(petadoptapp.collectionUser)
                  .document(petadoptapp.sharedPreferences
                  .getString(petadoptapp.userUID))
                  .collection(petadoptapp.collectionPost)
                  .limit(15)
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
              builder: (context, dataSnaphot) {
                return !dataSnaphot.hasData
                    ? SliverToBoxAdapter(
                  child: Center(
                    child: circularProgress(),
                  ),
                )
                    : SliverStaggeredGrid.countBuilder(
                  crossAxisCount: 1,
                  staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                  itemBuilder: (context, index) {
                    ItemModel model = ItemModel.fromJson(
                        dataSnaphot.data.documents[index].data);
                    distancefinder(model.location.longitude,
                        model.location.latitude);
                    return usersourceInfo(model, distance, context);
                  },
                  itemCount: dataSnaphot.data.documents.length,
                );
              }),
        ],
      ),
    );
  }

  Widget usersourceInfo(ItemModel model, String dis, BuildContext context,
      {Color background, removeCartFunction}) {
    if (model.category.toLowerCase().contains(_searchtextEditingController.text.toLowerCase()) || model.breed.toLowerCase().contains(_searchtextEditingController.text.toLowerCase()) || model.color.toLowerCase().contains(_searchtextEditingController.text.toLowerCase())) {
      return InkWell(
        onTap: () {
          Route route = MaterialPageRoute(
              builder: (c) => ProductPage(itemModel: model, page: "upload"));
          Navigator.pushReplacement(context, route);
        },
        splashColor: Colors.orange,
        child: Container(
          width: double.infinity,
          height: 280.0,
// color: Colors.red[100],
          margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Stack(
            children: [
              Positioned(
                top: 35,
                left: 0,
                right: 0,
                bottom: 15,
                child: Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(165, 10, 0, 7),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 120,
                              child:Text(
                                model.breed,
                                overflow: TextOverflow.ellipsis,
                                style: kTitleStyle,
                              ),
                            ),

                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.pinkAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                editItem(model, context);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber.shade50,
                              ),
                              child: Icon(
                                Icons.category,
                                color: Colors.amber.shade400,
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Category: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(model.category, style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[50],
                              ),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.blue[900],
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Age: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(model.age.toString() + " Years",
                                style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green[50],
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.green[900],
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Distance: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(dis + " Km", style: kSubtitle2Style),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(width: 5.0),
                            IconButton(
                              icon: Icon(
                                Icons.delete_rounded,
                                color: Colors.pinkAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: Text(
                                          "Are you sure you want to Delete This Post?"),
//content: Text("Are you sure you want to exit?"),
                                      actions: [
                                        CupertinoDialogAction(
                                            child: Text("Yes"),
                                            onPressed: () => {
                                              deleteItem(
                                                  model, context),
                                              Navigator.pop(
                                                  context, false)
                                            }),
                                        CupertinoDialogAction(
                                            child: Text("No"),
                                            onPressed: () => Navigator.pop(
                                                context, false)),
                                      ],
                                    ));
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 25,
                left: 0,
                right: 200,
                bottom: 10,

                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.network(
                    model.thumbnailUrl1,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_searchtextEditingController.text.isEmpty) {
      return InkWell(
        onTap: () {
          Route route = MaterialPageRoute(
              builder: (c) => ProductPage(itemModel: model, page: "upload"));
          Navigator.pushReplacement(context, route);
        },
        splashColor: Colors.orange,
        child: Container(
          width: double.infinity,
          height: 225.0,
// color: Colors.red[100],
          margin: EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
          child: Stack(
            children: [
              Positioned(
                top: 35,
                left: 0,
                right: 0,
                bottom: 15,
                child: Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(165, 10, 0, 7),
                    padding: EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              model.breed,
                              overflow: TextOverflow.ellipsis,
                              style: kTitleStyle,
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.pinkAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                editItem(model, context);
                              },
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber.shade50,
                              ),
                              child: Icon(
                                Icons.category,
                                color: Colors.amber.shade400,
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Category: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(model.category, style: kSubtitle2Style),
                          ],
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue[50],
                              ),
                              child: Icon(
                                Icons.calendar_today_outlined,
                                color: Colors.blue[900],
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Age: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(model.age.toString() + "Years",
                                style: kSubtitle2Style),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.green[50],
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.green[900],
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Distance: ",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: kText2Color,
                              ),
                            ),
                            Text(dis + " Km", style: kSubtitle2Style),
                            IconButton(
                              icon: Icon(
                                Icons.delete_rounded,
                                color: Colors.pinkAccent,
                                size: 20,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: Text(
                                          "Are you sure you want to Delete This Post?"),
//content: Text("Are you sure you want to exit?"),
                                      actions: [
                                        CupertinoDialogAction(
                                            child: Text("Yes"),
                                            onPressed: () => {
                                              deleteItem(
                                                  model, context),
                                              Navigator.pop(
                                                  context, false)
                                            }),
                                        CupertinoDialogAction(
                                            child: Text("No"),
                                            onPressed: () => Navigator.pop(
                                                context, false)),
                                      ],
                                    ));
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 25,
                left: 0,
                right: 200,
                bottom: 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.network(
                    model.thumbnailUrl1,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else
      return Container(
        child: SizedBox(
          height: 1,
        ),
      );
  }

  /*takeImage(mContext) {
    return showDialog(
        context: mContext,
        builder: (con) {
          return SimpleDialog(
            title: Text(
              "Item Image",
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
            children: [
              SimpleDialogOption(
                child: Text(
                  "Capture with camera",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                onPressed: capturePhotoWithCamera,
              ),
              SimpleDialogOption(
                child: Text(
                  "Pick from Gallery",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                onPressed: PickPhotoFromGallery,
              ),
              SimpleDialogOption(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }*/

  /*capturePhotoWithCamera() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 970.0, maxHeight: 600.0);
    setState(() {
      file = imageFile;
    });
  }

  PickPhotoFromGallery() async {
    Navigator.pop(context);
    File imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      file = imageFile;
    });
  }
*/

  displayAdminUploadFormScreen() {
    Future<bool> _onBackPressed() {
      return showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("Are you sure you want to exit?"),
            //content: Text("Are you sure you want to exit?"),
            actions: [
              CupertinoDialogAction(
                  child: Text("Yes"),
                  onPressed: () =>
                  {clearFormInfo(), Navigator.pop(context, false)}),
              CupertinoDialogAction(
                  child: Text("No"),
                  onPressed: () => Navigator.pop(context, false)),
            ],
          ));
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xfffbb448), Color(0xfff7892b)]),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _onBackPressed,
          ),
          title: Text(
            "Create Post",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            FlatButton(
              onPressed: uploading ? null : () => uploadImageAndSaveItemInfo(),
              child: Text(
                "Add",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            uploading ? linearProgress() : Text(""),
            Container(
              height: 180.0,
              width: MediaQuery.of(context).size.width * 0.8,
              /*child: file != null
                  ? Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(file), fit: BoxFit.cover)),
                    )
                  : Container(
                      decoration: new BoxDecoration(
                          image: new DecorationImage(
                      image: new AssetImage("images/admin.png"),
                      fit: BoxFit.fill,
                    )))*/
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    children: [
                      GestureDetector(
                        onTap: _getImage1,
                        child: Container(
                          color: Colors.black12,
                          child: _image1 == null
                              ? Icon(Icons.add)
                              : FittedBox(
                            child: Image.file(_image1),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _getImage2,
                        child: Container(
                          color: Colors.black12,
                          child: _image2 == null
                              ? Icon(Icons.add)
                              : FittedBox(
                            child: Image.file(_image2),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _getImage3,
                        child: Container(
                          color: Colors.black12,
                          child: _image3 == null
                              ? Icon(Icons.add)
                              : FittedBox(
                            child: Image.file(_image3),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.0),
            ),
            /* ListTile(
            title: IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.grey),
              onPressed: () => takeImage(context),
            ),
          ),*/
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"[a-zA-Z]+|\s")),
                  ],
                  controller: _breedtextEditingController,
                  autofocus: true,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Breed*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _breedFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    if(_breedtextEditingController.text.length > 1 )
                    { return null; }
                    else
                    {
                      return "Required Text Input";
                    }
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"[a-zA-Z]+|\s")),
                  ],
                  controller: _categorytextEditingController,
                  autofocus: true,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Category*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _categoryFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    return _categorytextEditingController.text.length > 1
                        ? null
                        : 'Required';
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(

                  controller: _agetextEditingController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Age*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _ageFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    return _agetextEditingController.text.length > 0 && double.parse(_agetextEditingController.text) < 100
                        ? null
                        : 'Requires age between 0 to 100 years';
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"[a-zA-Z]+|\s")),
                  ],
                  controller: _colortextEditingController,
                  autofocus: true,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Color",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(

                  controller: _weighttextEditingController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Weight*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _weightFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    return _weighttextEditingController.text.length > 0 && double.parse(_weighttextEditingController.text) < 1000
                        ? null
                        :'Requires age between 0 to 1000 Kg';
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  maxLength: 11,

                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"[0-9]")),
                  ],
                  controller: _phonetextEditingController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Phone*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _phoneFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    return _phonetextEditingController.text.length == 11
                        ? null
                        : 'Enter Valid Phone Number';
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Container(
                width: 300.0,
                child: TextFormField(
                  controller: _locationtextEditingController,
                  autofocus: true,
                  enabled: false,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Location*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
              title: IconButton(
                icon: Icon(Icons.location_on, color: Colors.black),
                onPressed: () => setDisplay("loc"),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  maxLines: 4,
                  controller: _infotextEditingController,
                  autofocus: true,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Description",
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  clearFormInfo() {
    setState(() {
      uploading = false;
      _image1 = null;
      _image2 = null;
      _image3 = null;
      _breedtextEditingController.clear();
      _colortextEditingController.clear();
      _infotextEditingController.clear();
      _agetextEditingController.clear();
      _phonetextEditingController.clear();
      _categorytextEditingController.clear();
      _locationtextEditingController.clear();
      _weighttextEditingController.clear();
      productId = ctime.toString();
      setDisplay("home");
      getloc();
    });
  }

  uploadImageAndSaveItemInfo() async {


    if (_image1 == null && _image2 == null && _image3 == null) {
      Fluttertoast.showToast(msg: "Please Upload At least one image");
    }
    else{

      showDialog(
          context:context,
          builder: (c)
          {
            return LoadingAlertDialog(message: "Submitting,Please wait....",);
          }
      );

      if (_isFormValid()) {
        setState(() {
          uploading = true;
        });

        String imageDownloadUrl1 = null;
        String imageDownloadUrl2 = null;
        String imageDownloadUrl3 = null;
        if (_image1 != null) {
          imageDownloadUrl1 = await uploadItemImage(_image1);
        }

        if (_image2 != null) {
          imageDownloadUrl2 = await uploadItemImage(_image2);
        }

        if (_image3 != null) {
          imageDownloadUrl3 = await uploadItemImage(_image3);
        }

        if (_image1 == null && _image2 != null) {
          imageDownloadUrl1 = imageDownloadUrl2;
          setState(() {
            _image1 = _image2;
            _image2 = null;
            imageDownloadUrl2 = null;
          });
        } else if (_image1 == null && _image3 != null) {
          imageDownloadUrl1 = imageDownloadUrl3;
          setState(() {
            _image1 = _image3;
            _image3 = null;
            imageDownloadUrl3 = null;
          });
        }

        saveItemInfo(imageDownloadUrl1, imageDownloadUrl2, imageDownloadUrl3);
      }
    }


  }

  Future<String> uploadItemImage(mFileImage) async {
    productId = DateTime.now().millisecondsSinceEpoch.toString();
    final StorageReference storageReference =
    FirebaseStorage.instance.ref().child("ads");
    StorageUploadTask uploadTask =
    storageReference.child("product_$productId.jpg").putFile(mFileImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    String downloadurl = await taskSnapshot.ref.getDownloadURL();
    return downloadurl;
  }

  Future saveItemInfo(
      String downloadUrl1, String downloadUrl2, String downloadUrl3) async {
    if (loc == null) {
      await getloc();
    }
    ctime = DateTime.now();
    final itemsRef = Firestore.instance.collection("ads");
    itemsRef
        .document(ctime.millisecondsSinceEpoch.toString() +
        petadoptapp.sharedPreferences
            .getString(petadoptapp.userUID)
            .toString())
        .setData({
      "info": _infotextEditingController.text.trim(),
      "color": _colortextEditingController.text.trim(),
      "age": _agetextEditingController.text.trim(),
      "breed": _breedtextEditingController.text.trim(),
      "category": _categorytextEditingController.text.trim(),
      "location": loc,
      "phone": _phonetextEditingController.text.trim(),
      "uid": petadoptapp.sharedPreferences
          .getString(petadoptapp.userUID)
          .toString(),
      "weight": _weighttextEditingController.text.trim(),
      "publishedDate": ctime,
      "thumbnailUrl1": downloadUrl1,
      "thumbnailUrl2": downloadUrl2,
      "thumbnailUrl3": downloadUrl3,
    });

    await petadoptapp.firestore
        .collection(petadoptapp.collectionUser)
        .document(petadoptapp.sharedPreferences.getString(petadoptapp.userUID))
        .collection(petadoptapp.collectionPost)
        .document(ctime.millisecondsSinceEpoch.toString() +
        petadoptapp.sharedPreferences.getString(petadoptapp.userUID))
        .setData({
      "info": _infotextEditingController.text.trim(),
      "color": _colortextEditingController.text.trim(),
      "age": _agetextEditingController.text.trim(),
      "breed": _breedtextEditingController.text.trim(),
      "category": _categorytextEditingController.text.trim(),
      "location": loc,
      "phone": _phonetextEditingController.text.trim(),
      "uid": petadoptapp.sharedPreferences
          .getString(petadoptapp.userUID)
          .toString(),
      "weight": _weighttextEditingController.text.trim(),
      "publishedDate": ctime,
      "thumbnailUrl1": downloadUrl1,
      "thumbnailUrl2": downloadUrl2,
      "thumbnailUrl3": downloadUrl3,
    }).then((v) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Post Added Successfully");
    });

    clearFormInfo();
  }

  bool validatePassword() {
    return true;
  }

  bool _isFormValid() {
    if (_breedtextEditingController.text.length > 1 &&
        _categorytextEditingController.text.length > 1 &&
        _agetextEditingController.text.length > 0 &&
        _weighttextEditingController.text.length > 0 &&
        _phonetextEditingController.text.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  void setDisplay(String state) {
    setState(() {
      display = state;
    });
  }

  Future deleteItem(ItemModel model, BuildContext context) async {
    await petadoptapp.firestore
        .collection("users")
        .document(model.uid)
        .collection("post")
        .document(model.publishedDate.millisecondsSinceEpoch.toString() +
        model.uid.toString())
        .delete()
        .then((v) {
      Fluttertoast.showToast(msg: "Post Deleted");
    });

    await petadoptapp.firestore
        .collection("ads")
        .document(model.publishedDate.millisecondsSinceEpoch.toString() +
        model.uid.toString())
        .delete();
  }

  editFormScreen() {
    Future<bool> _onBackPressed() {
      return showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text("Are you sure you want to exit?"),
            //content: Text("Are you sure you want to exit?"),
            actions: [
              CupertinoDialogAction(
                  child: Text("Yes"),
                  onPressed: () =>
                  {clearFormInfo(), Navigator.pop(context, false)}),
              CupertinoDialogAction(
                  child: Text("No"),
                  onPressed: () => Navigator.pop(context, false)),
            ],
          ));
    }

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: new BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xfffbb448), Color(0xfff7892b)]),
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _onBackPressed,
          ),
          title: Text(
            "Edit Post",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            FlatButton(
              onPressed: uploading ? null : () => editImageAndSaveItemInfo(),
              child: Text(
                "Update",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        body: ListView(
          children: [
            uploading ? linearProgress() : Text(""),
            Container(
              height: 180.0,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    primary: false,
                    padding: const EdgeInsets.all(20),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    crossAxisCount: 3,
                    children: [
                      GestureDetector(
                        onTap: _editgetImage1,
                        child: Container(
                          color: Colors.black12,
                          child: tempModel.thumbnailUrl1 == null
                              ? Icon(Icons.add)
                              : FittedBox(
                            child: Image.network(
                              tempModel.thumbnailUrl1,
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _editgetImage2,
                        child: Container(
                          color: Colors.black12,
                          child: tempModel.thumbnailUrl2 == null
                              ? Icon(Icons.add)
                              : FittedBox(
                            child: Image.network(
                              tempModel.thumbnailUrl2,
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _editgetImage3,
                        child: Container(
                          color: Colors.black12,
                          child: tempModel.thumbnailUrl3 == null
                              ? Icon(Icons.add)
                              : FittedBox(
                            child: Image.network(
                              tempModel.thumbnailUrl3,
                            ),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 12.0),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"[a-zA-Z]+|\s")),
                  ],
                  controller: _breedtextEditingController,
                  autofocus: true,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Breed*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _breedFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    if(_breedtextEditingController.text.length > 1 )
                    { return null; }
                    else
                    {
                      return "Required Text Input";
                    }
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"[a-zA-Z]+|\s")),
                  ],
                  controller: _categorytextEditingController,
                  autofocus: true,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Category*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _categoryFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    if(_categorytextEditingController.text.length > 1 )
                    { return null; }
                    else
                    {
                      return "Required Text Input";
                    }
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(

                  controller: _agetextEditingController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Age*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _ageFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    return _agetextEditingController.text.length > 0 && double.parse(_agetextEditingController.text) < 100
                        ? null
                        : 'Requires age between 0 to 100 years';
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  controller: _colortextEditingController,
                  autofocus: true,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Color",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(

                  controller: _weighttextEditingController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Weight*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _weightFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    return _weighttextEditingController.text.length > 0 && double.parse(_weighttextEditingController.text) < 1000
                        ? null
                        :'Requires age between 0 to 1000 Kg';
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  maxLength: 11,
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp(r"[0-9]")),
                  ],
                  controller: _phonetextEditingController,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Phone*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isSubmitButtonEnabled = _isFormValid();
                      _phoneFormKey.currentState.validate();
                    });
                  },
                  validator: (value) {
                    return _phonetextEditingController.text.length == 11
                        ? null
                        : 'Enter Valid Phone Number';
                  },
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Container(
                width: 300.0,
                child: TextFormField(
                  controller: _locationtextEditingController,
                  autofocus: true,
                  enabled: false,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Location*",
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
              title: IconButton(
                icon: Icon(Icons.location_on, color: Colors.black),
                onPressed: () => setDisplay("loc"),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            ListTile(
              title: Container(
                width: 250.0,
                child: TextFormField(
                  maxLines: 4,
                  controller: _infotextEditingController,
                  autofocus: true,
                  autovalidate: validatePassword(),
                  onEditingComplete: () {
                    debugPrint("Completed");
                    FocusScope.of(context).requestFocus(myFocusNode);
                  },
                  decoration: new InputDecoration(
                    focusColor: Colors.black,
                    labelText: "Description",
                    alignLabelWithHint: true,
                    labelStyle: TextStyle(color: Colors.black, fontSize: 20.0),
                    enabledBorder: const OutlineInputBorder(
                      borderSide:
                      const BorderSide(color: Colors.grey, width: 0.0),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  style: TextStyle(
                    fontFamily: "TepenoRegular",
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  editImageAndSaveItemInfo() async {
    if (_isFormValid()) {
      setState(() {
        uploading = true;
      });

      showDialog(
          context:context,
          builder: (c)
          {
            return LoadingAlertDialog(message: "Updating,Please wait....",);
          }
      );

      String imageDownloadUrl1 = tempModel.thumbnailUrl1;
      String imageDownloadUrl2 = tempModel.thumbnailUrl2;
      String imageDownloadUrl3 = tempModel.thumbnailUrl3;
      if (_image1 != null) {
        imageDownloadUrl1 = await uploadItemImage(_image1);
      }

      if (_image2 != null) {
        imageDownloadUrl2 = await uploadItemImage(_image2);
      }

      if (_image3 != null) {
        imageDownloadUrl3 = await uploadItemImage(_image3);
      }

      editItemInfo(imageDownloadUrl1, imageDownloadUrl2, imageDownloadUrl3);
    }
  }

  Future editItemInfo(
      String downloadUrl1, String downloadUrl2, String downloadUrl3) async {

    final itemsRef = Firestore.instance.collection("ads");
    itemsRef
        .document(tempModel.publishedDate.millisecondsSinceEpoch.toString() +
        tempModel.uid)
        .setData({
      "info": _infotextEditingController.text.trim(),
      "color": _colortextEditingController.text.trim(),
      "age": _agetextEditingController.text.trim(),
      "breed": _breedtextEditingController.text.trim(),
      "category": _categorytextEditingController.text.trim(),
      "location": loc,
      "phone": _phonetextEditingController.text.trim(),
      "uid": tempModel.uid,
      "weight": _weighttextEditingController.text.trim(),
      "publishedDate": tempModel.publishedDate,
      "thumbnailUrl1": downloadUrl1,
      "thumbnailUrl2": downloadUrl2,
      "thumbnailUrl3": downloadUrl3,
    });

    await petadoptapp.firestore
        .collection("users")
        .document(tempModel.uid)
        .collection("post")
        .document(tempModel.publishedDate.millisecondsSinceEpoch.toString() +
        tempModel.uid)
        .setData({
      "info": _infotextEditingController.text.trim(),
      "color": _colortextEditingController.text.trim(),
      "age": _agetextEditingController.text.trim(),
      "breed": _breedtextEditingController.text.trim(),
      "category": _categorytextEditingController.text.trim(),
      "location": loc,
      "phone": _phonetextEditingController.text.trim(),
      "uid": tempModel.uid,
      "weight": _weighttextEditingController.text.trim(),
      "publishedDate": tempModel.publishedDate,
      "thumbnailUrl1": downloadUrl1,
      "thumbnailUrl2": downloadUrl2,
      "thumbnailUrl3": downloadUrl3,
    }).then((v) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Post Updated Successfully");
    });

    clearFormInfo();
  }

  Widget searchWidget() {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      alignment: Alignment.topCenter,
      width: MediaQuery.of(context).size.width - 40.0,
      height: 60.0,
      decoration: new BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xfffbb448), Color(0xfff7892b)]),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width - 40.0,
        height: 60.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
        ),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.search,
                color: Colors.blueGrey,
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: TextField(
                  controller: _searchtextEditingController,
                  onChanged: (value) {
                    startSearching();
                  },
                  decoration:
                  InputDecoration.collapsed(hintText: "Search here..."),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future editItem(ItemModel model, BuildContext context) async {
    tempModel = model;

    setDisplay("edit");
    loc = model.location;
    await locationHandler();
    setState(() {
      _breedtextEditingController.value = TextEditingValue(text: model.breed);
      _categorytextEditingController.value =
          TextEditingValue(text: model.category);
      _agetextEditingController.value =
          TextEditingValue(text: model.age.toString());
      _colortextEditingController.value = TextEditingValue(text: model.color);
      _weighttextEditingController.value = TextEditingValue(text: model.weight);
      _phonetextEditingController.value = TextEditingValue(text: model.phone);
      _infotextEditingController.value = TextEditingValue(text: model.info);
    });
  }

  Future editItemaftermap(BuildContext context) async {
    setDisplay("edit");
  }

  Future getloc() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      uploading = false;
      if (!_serviceEnabled) {
        Fluttertoast.showToast(msg: "Location Service Not Enabled");
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      uploading = false;
      if (_permissionGranted != PermissionStatus.granted) {
        Fluttertoast.showToast(msg: "Location Service Not Enabled");
      }
    }

    _locationData = await location.getLocation();
    loc = new GeoPoint(_locationData.latitude, _locationData.longitude);
  }

  Future _getImage1() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image1 = image;
    });
  }

  Future _getImage2() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image2 = image;
    });
  }

  Future _getImage3() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image3 = image;
    });
  }

  Future _editgetImage1() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _image1 = image;
    String thumbnailUrl1 = await uploadItemImage(_image1);

    setState(() {
      tempModel.thumbnailUrl1 = thumbnailUrl1;
    });
  }

  Future _editgetImage2() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _image2 = image;
    String thumbnailUrl2 = await uploadItemImage(_image2);
    setState(() {
      tempModel.thumbnailUrl2 = thumbnailUrl2;
    });
  }

  Future _editgetImage3() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    _image3 = image;
    String thumbnailUrl3 = await uploadItemImage(_image3);
    setState(() {
      tempModel.thumbnailUrl3 = thumbnailUrl3;
    });
  }

  Future locationHandler() async {
    double i = loc.latitude;
    double j = loc.longitude;
    print(i);
    print(j);
    final coordinates = new Coordinates(i, j);

    var addresses =await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    setState(() {
      _locationtextEditingController.value =
          TextEditingValue(text: first.addressLine);
    });
  }

  Future distancefinder(double lon, double lat) async {
    if (tlat == null || tlong == null) {
      Location location = new Location();

      bool _serviceEnabled;
      PermissionStatus _permissionGranted;
      LocationData _locationData = await location.getLocation();

      _serviceEnabled = await location.serviceEnabled();
      if (!_serviceEnabled) {
        _serviceEnabled = await location.requestService();

        if (!_serviceEnabled) {
          Fluttertoast.showToast(msg: "Location Service Not Enabled");
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();

        if (_permissionGranted != PermissionStatus.granted) {
          Fluttertoast.showToast(msg: "Location Service Not Enabled");
        }
      }

      // print(_locationData.latitude);
      // print(_locationData.longitude);
      // print(lat);
      // print(lon);
      tlat = _locationData.latitude;
      tlong = _locationData.longitude;

      _center = LatLng(tlat, tlong);
      temp = _center;
    }

    double distanceInMeters = Geolocator.distanceBetween(tlat, tlong, lat, lon);
    distanceInMeters = distanceInMeters / 1000;
    setState(() {
      distance = distanceInMeters.toStringAsFixed(1);
    });
  }

  locationpage() {
    Future<bool> _onlocBackPressed() {
      if (!onedit) {
        setDisplay("post");
      } else if (onedit) {
        editItemaftermap(context);
      }
    }

    return WillPopScope(
      onWillPop: _onlocBackPressed,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              'Select Location',
              textAlign: TextAlign.center,
            ),
            brightness: Brightness.light,
            backgroundColor: Colors.orangeAccent,
            elevation: 0,
            leading: GestureDetector(
              onTap: () {
                editItemaftermap(context);
              },
              child: Icon(
                Icons.arrow_back,
                color: Colors.grey[800],
              ),
            ),
          ),
          body: Stack(
            children: <Widget>[
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _center,
                  zoom: 11.0,
                ),
                mapType: _currentMapType,
                onCameraMove: _onCameraMove,
              ),
              Positioned(
                child: Icon(
                  Icons.location_on,
                  color: Colors.blue,
                  size: 40,
                ),
                bottom: 0,
                left: 0,
                right: 0,
                top: 0,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    children: <Widget>[
                      FloatingActionButton(
                        onPressed: () => setlocation(),
                        materialTapTargetSize: MaterialTapTargetSize.padded,
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.done, size: 36.0),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onCameraMove(CameraPosition position) {
    temp = position.target;

  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  setlocation() async {
    print(temp);

    loc =  new GeoPoint(temp.latitude, temp.longitude);

    await locationHandler();
    if (!onedit) {
      setDisplay("post");
    } else if (onedit) {
      editItemaftermap(context);
    }
  }
}
