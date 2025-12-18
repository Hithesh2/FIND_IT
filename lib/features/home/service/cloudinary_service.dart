import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:find_it_app/core/constants/cloudinary_config.dart';

class CloudinaryService {
  // Upload a single image to Cloudinary and return the URL
  Future<String> uploadImage(File imageFile) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload'),
      );

      // Add upload preset (unsigned)
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset;

      // Add the image file
      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );
      request.files.add(multipartFile);

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final imageUrl = responseData['secure_url'] as String;
        print('✅ Image uploaded successfully: $imageUrl');
        return imageUrl;
      } else {
        print('❌ Error uploading image: ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception('Failed to upload image: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error in uploadImage: $e');
      throw Exception('Failed to upload image: ${e.toString()}');
    }
  }

  // Upload multiple images and return list of URLs
  Future<List<String>> uploadImages(List<File> imageFiles) async {
    List<String> imageUrls = [];
    
    for (var imageFile in imageFiles) {
      try {
        final url = await uploadImage(imageFile);
        imageUrls.add(url);
      } catch (e) {
        print('❌ Error uploading image: $e');
        // Continue with other images even if one fails
        // You can choose to throw here if you want to stop on first error
      }
    }
    
    return imageUrls;
  }
}

