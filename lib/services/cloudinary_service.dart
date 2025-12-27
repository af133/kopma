import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final CloudinaryPublic cloudinary = CloudinaryPublic('ds62ywc1c', 'kopma_preset');

  Future<CloudinaryResponse> uploadImage(XFile imageFile) async {
    return cloudinary.uploadFile(
      CloudinaryFile.fromFile(imageFile.path, resourceType: CloudinaryResourceType.Image),
    );
  }
}
