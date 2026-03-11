import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:excel/app_styles/app_button_styles.dart';
import 'package:excel/app_styles/app_colors.dart';
import 'package:excel/widgets/app_bar.dart';
import '../utils/camera.dart';
import '../widgets/custom_loader.dart';
import 'detection_screen.dart';

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ImagePreviewScreen extends ConsumerWidget {
  final File imageFile;

  const ImagePreviewScreen({
    super.key,
    required this.imageFile,
  });

  void _cameraClick(BuildContext context) async{
    File? imageFile = await CameraUtils.pickImageFromCamera();

    if (imageFile != null && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ImagePreviewScreen(imageFile: imageFile),
        ),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchData() async {
    // 1. Parse the URL0
    // Use 10.0.2.2 for Android Emulator, localhost for iOS/Web
    // IP4 - 10.250.54.35
    final url = Uri.parse('https://excel-project-9gdf.onrender.com/detect');
    try {
      var request = http.MultipartRequest('POST', url);
      // Add the file to the request
      // 'file' matches the parameter name in your FastAPI function: detect_waste(file: ...)
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', 
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      );
      // 3. Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      // 4. Check if the server responded correctly (Status 200)
      if (response.statusCode == 200) {
        // 5. Parse/Decode the data
        Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        print('Request failed with status: ${response.statusCode}. Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error connecting to backend: $e');
      return null;
    }
  }


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appButtons = ref.watch(appButtonsProvider);
    final appColors = ref.watch(appColorsProvider);

    return Scaffold(
      backgroundColor: appColors.background,
      appBar: AppAppBar(name: "Preview"),
      body: Column(
        children: [
          Expanded(
            child: Image.file(
              imageFile,
              width: double.infinity,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _cameraClick(context),
                    style: appButtons.themeOutlinedButton,
                    child: Text("Retake", style: TextStyle(color: appColors.gold),),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // 1. Show a loading indicator (optional but good practice)
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: ClassicLoader()),
                      );

                      // 2. Fetch the data
                      Map<String, dynamic>? data = await fetchData();

                      // 3. Close the loading indicator
                      if (context.mounted) Navigator.pop(context);

                      if(data != null && context.mounted){
                        // 4. Navigating to next Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DetectionScreen(
                            imageFile: imageFile,
                            waste: data['waste_type'] ?? 'Unknown',
                            qty: (data['quantity'] ?? 'Unknown').toString(),
                            dispose: List<String>.from(data['disposal_methods'] ?? []),
                            donts: List<String>.from(data['mistakes_to_avoid'] ?? []),
                          ),),
                        );
                      }else{
                        if(context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Error connecting to backend")
                            )
                          );
                        }
                      }

                    },
                    style: appButtons.themeButton,
                    child: Text("Proceed",style: TextStyle(color: Colors.white),),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
