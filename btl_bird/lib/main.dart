import 'package:bird_classifier_app/pages/color_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';
import 'package:bird_classifier_app/pages/data_used.dart';
import 'package:bird_classifier_app/pages/model_architecture.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

void main() => runApp(MaterialApp(
  theme: ThemeData(
    primaryColor: Colors.red,
  ),
  debugShowCheckedModeBanner: false,
  title: "Phân biệt loài chim",
  initialRoute: '/',
  routes: {
    '/': (context) => HomePage(),
    '/dataUsed': (context) => DataUsed(),
    '/modelArchitecture': (context) => ModelArchitecture(),
  },
));

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  File? _image;
  PickedFile? _pickedFile;
  final _picker = ImagePicker();

  List? _result;
  String? _confidence = "";
  String? _name = "";
  String? numbers = "";

  pickImageFromCamera() async {
    _pickedFile = await _picker.getImage(
      source: ImageSource.camera,
    );

    if(_pickedFile != null) {
      setState(() {
        _image = File(_pickedFile!.path);
      });
    }
  }

  pickImageFromGalleryOrGDrive() async {
    _pickedFile = await _picker.getImage(
        source: ImageSource.gallery,
    );

    if(_pickedFile != null) {
      setState(() {
        _image = File(_pickedFile!.path);
      });
    }
  }

  loadMyModel() async {
    var resultant = await Tflite.loadModel(
      labels: "assets/labels.txt",
      model: "assets/bird_classifier.tflite"
    );
    print("Result after loading the model: $resultant");
  }

  applyModelOnImage(File file) async {
    var res = await Tflite.runModelOnImage(
        path: file.path,
        numResults: 400,
        threshold: 0.3,
        imageMean: 127.5,
        imageStd: 127.5
    );

    setState(() {
      _result = res;
      String? str = _result?[0]["label"];
      _name = str?.substring(str.length - (str.length - 3));
      _confidence = _result != null ? (_result?[0]["confidence"] * 100.0).toString().substring(0, 2) + "%": "";
      print("Name: $_name\nConfidence: $_confidence");
    });
  }

  @override
  void initState() {
    super.initState();
    loadMyModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFB0D4B8),
      appBar: AppBar(
        title: Text(
            "Phân biệt loài chim",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 25,
            ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF5D7B6F),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 25),
            _pickedFile != null
            ? Center(
              child: Container(
                height: 350,
                width: 350,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(_pickedFile!.path)),
                    fit: BoxFit.contain,
                  ),
                ),

              ),
            )
                : Container(
                  padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
                  height: 350,
                  width: 350,
                  color: Color(0xFFEAE7D6),
                  child: Align(
                    alignment: Alignment.center,
                    child: Padding(
                        padding: EdgeInsets.fromLTRB(30, 0, 50, 0),
                        child: Text(
                            "Vui lòng chọn ảnh",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                        ),
                    ),
                  ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(22, 0, 22, 0),
              // decoration: BoxDecoration(
              //   borderRadius: BorderRadius.circular(10),
              // ),
              color: ColorPage().a,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          "    Loài chim: ",
                          style: TextStyle(
                            color: ColorPage().c,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          )
                      ),
                      Text(
                        "$_name",
                        style: TextStyle(
                          color: ColorPage().c,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                          "    Xác suất (Confidence): ",
                          style: TextStyle(
                            color: ColorPage().c,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          )
                      ),
                      Text(
                        "$_confidence",
                        style: TextStyle(
                          color: ColorPage().c,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       Text(
          //           "Loài chim: ",
          //           style: TextStyle(
          //             color: ColorPage().c,
          //             fontWeight: FontWeight.bold,
          //             fontSize: 20,
          //           )
          //       ),
          //       Text(
          //         "$_name",
          //         style: TextStyle(
          //           color: Colors.white70,
          //           fontSize: 20,
          //         ),
          //       ),
          //     ],
          //   ),
          //   SizedBox(
          //     height: 10,
          //   ),
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.start,
          //     children: [
          //       Text(
          //           "Xác suất (Confidence): ",
          //           style: TextStyle(
          //             color: ColorPage().c,
          //             fontWeight: FontWeight.bold,
          //             fontSize: 20,
          //           )
          //       ),
          //       Text(
          //         "$_confidence",
          //         style: TextStyle(
          //           color: Colors.white70,
          //           fontSize: 20,
          //         ),
          //       ),
          //     ],
          //  ),
            SizedBox(
              height: 20,
            ),
            TextButton(
              // minWidth: 225,
              onPressed: () {
                applyModelOnImage(File(_pickedFile!.path));
              },
              child: Text(
                  "Dự đoán",
                style: TextStyle(
                  color: Color(0xFFEAE7D6),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )
              ),
              // color: Colors.blue,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF5D7B6F)),
                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.fromLTRB(25, 10, 25, 10)),
            
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 225,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => new DataUsed(),
                    ),
                  );
                },
                child: Text(
                  "Data Used",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5D7B6F)
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 225,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    new MaterialPageRoute(
                      builder: (context) => new ModelArchitecture(),
                    ),
                  );
                  
                },
                child: Text(
                  "Model Architecture",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5D7B6F)
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        foregroundColor: Color(0xFF5D7B6F),
        backgroundColor: Colors.white,
        spacing: 5,
        spaceBetweenChildren: 5,
        closeManually: false,
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.camera, 
              color: Color(0xFF5D7B6F),
            ),
            onTap: () => pickImageFromCamera(),
          ),
          SpeedDialChild(
            child: Icon(
              Icons.photo_album,
              color: Color(0xFF5D7B6F),
            ),
            onTap: () => pickImageFromGalleryOrGDrive(),
          ),
        ],
      ),
    );
  }
}
