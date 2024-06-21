import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/neopop.dart'; // Import the NeoPop package

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Plant Disease Predictor',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.yellow, // Change the AppBar color to yellow
        hintColor: Colors.yellowAccent,
        scaffoldBackgroundColor: Colors.black, // Change background to black
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;
  final picker = ImagePicker();
  String? _prediction;
  bool _loading = false;

  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _prediction = null; // Reset the prediction when a new image is selected
      });
    } else {
      print('No image selected.');
    }
  }

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _prediction = null; // Reset the prediction when a new image is selected
      });
    } else {
      print('No image captured.');
    }
  }

  Future uploadImage(File imageFile) async {
    setState(() {
      _loading = true; // Show loading indicator
    });

    try {
      final uri =
          Uri.parse("https://keen-marcie-vengood-1ac8fc2f.koyeb.app/predict");
      var request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final decodedResponse = jsonDecode(respStr);
        setState(() {
          _prediction = decodedResponse['disease'];
        });
      } else {
        final respStr = await response.stream.bytesToString();
        print('Error response: $respStr');
        setState(() {
          _prediction = 'Error: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      print('Exception: $e');
      setState(() {
        _prediction = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Plant Disease Predictor',
          style: GoogleFonts.cormorantGaramond(color: Colors.black),
        ),
        backgroundColor: Color.fromRGBO(255, 235, 52, 1),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null)
              Container(
                height: screenHeight * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: NeoPopTiltedButton(
                    isFloating: true,
                    onTapUp: getImageFromGallery,
                    decoration: const NeoPopTiltedButtonDecoration(
                      color: Color.fromRGBO(255, 235, 52, 1),
                      plunkColor: Color.fromRGBO(255, 235, 52, 1),
                      shadowColor: Color.fromRGBO(36, 36, 36, 1),
                      showShimmer: true,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(
                        'Upload Image',
                        style: GoogleFonts.playfairDisplay(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: NeoPopTiltedButton(
                    isFloating: true,
                    onTapUp: getImageFromCamera,
                    decoration: const NeoPopTiltedButtonDecoration(
                      color: Color.fromRGBO(255, 235, 52, 1),
                      plunkColor: Color.fromRGBO(255, 235, 52, 1),
                      shadowColor: Color.fromRGBO(36, 36, 36, 1),
                      showShimmer: true,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Text(
                        'Capture Image',
                        style: GoogleFonts.playfairDisplay(color: Colors.black),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            NeoPopTiltedButton(
              isFloating: true,
              onTapUp: () {
                if (_image != null) {
                  uploadImage(_image!);
                }
              },
              decoration: const NeoPopTiltedButtonDecoration(
                color: Color.fromRGBO(255, 235, 52, 1),
                plunkColor: Color.fromRGBO(255, 235, 52, 1),
                shadowColor: Color.fromRGBO(36, 36, 36, 1),
                showShimmer: true,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Container(
                  width: buttonWidth,
                  alignment: Alignment.center,
                  child: Text(
                    'Predict Disease',
                    style: GoogleFonts.playfairDisplay(color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            _loading
                ? CircularProgressIndicator()
                : _prediction == null
                    ? Text('No prediction yet.',
                        style: TextStyle(color: Colors.white))
                    : Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          'Prediction: $_prediction',
                          style:
                              GoogleFonts.playfairDisplay(color: Colors.black),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
