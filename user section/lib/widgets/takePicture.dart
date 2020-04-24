import 'package:camera/camera.dart';
import 'package:path/path.dart' show join;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'displayPic.dart';

class TakePictureScreen extends StatefulWidget {
  //final address;
  final camera;
  final initialLatitude, initialLongitude, landmark, pickedLocation;
  final bool food,women,clothes,medicine,children;
  TakePictureScreen(this.camera, this.initialLatitude, this.initialLongitude,
      this.landmark, this.pickedLocation, this.food, this.women, this.clothes, this.medicine, this.children);
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    //print(widget.camera);

    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,

      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture'),backgroundColor: Colors.black,),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 6,
        backgroundColor: Colors.teal,
        child: Icon(Icons.camera,size: 35,),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Construct the path where the image should be saved using the
            // pattern package.
            final path = join(
              // Store the picture in the temp directory.
              // Find the temp directory using the `path_provider` plugin.
              (await getTemporaryDirectory()).path,
              '${DateTime.now()}.png',
            );

            // Attempt to take a picture and log where it's been saved.
            await _controller.takePicture(path);

            // If the picture was taken, display it on a new screen.
            var path1 = await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DisplayPictureScreen(
                  imagePath: path,
                  initialLatitude: widget.initialLatitude,
                  initialLongitude: widget.initialLongitude,
                  landmark: widget.landmark,
                  pickedLocation: widget.pickedLocation,
                  cam: widget.camera,
                  food: widget.food,
                  clothes: widget.clothes,
                  women: widget.women,
                  medicine: widget.medicine,
                  children: widget.children,

                ),
              ),
            );
            Navigator.of(context).pop(path1);
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}
