import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:image_picker/image_picker.dart';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<File>? imageFile;
  File? _image;
  String result = '';
  ImagePicker? imagePicker;

  selectPhotoFromGallery() async{
    XFile? pickedFile = await imagePicker!.pickImage(source: ImageSource.gallery);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassification();
    });
  }

  capturePhotoFromCamera() async{
    XFile? pickedFile = await imagePicker!.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageClassification();
    });
  }

  loadDataModelFiles() async{
    String? output = await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
      numThreads: 1,
      isAsset: true,
      useGpuDelegate: false,
    );
    print(output);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    loadDataModelFiles();
  }

  doImageClassification() async{
    var recognitions = await Tflite.runModelOnImage(
      path: _image!.path,
      imageMean: 0.0,
      imageStd: 255.0,
      numResults: 2, // 2 results per image - prediction
      threshold: 0.1,
      asynch: true,
    );
    print(recognitions!.length.toString());
    setState(() {
      result = '';
    });
    recognitions.forEach((element) {
      setState(() {
        print(element.toString());
        result += element['label'] + "\n\n";
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            color: Colors.white
        ),
        child: Column(
          children: [
            const SizedBox(width: 100,),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              child: Stack(
                children: [
                  Center(
                    child: TextButton(
                      onPressed: selectPhotoFromGallery,
                      onLongPress: capturePhotoFromCamera,
                      child: Container(
                          margin: const EdgeInsets.only(top: 30.0,right: 35, left: 18.0),
                          child: _image!=null? Image.file(_image!, height: 360, width: 400, fit: BoxFit.cover,):
                          Container(
                            width: 140,
                            height: 190,
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.black,),
                          )
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 160.0,),
            Container(
              margin: const EdgeInsets.only(top: 20.0),
              padding: const EdgeInsets.only(top: 20.0),
              child: Text(
                '$result',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  backgroundColor: Colors.white30,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
