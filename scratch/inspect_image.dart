import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final bytes = File('assets/images/store-thump-icon.png').readAsBytesSync();
  final image = img.decodePng(bytes);
  if (image == null) {
    print('Error: Could not decode PNG');
    return;
  }
  print('Image dimensions: ${image.width}x${image.height}');
  print('Image channels: ${image.numChannels}');
  
  // Check corner pixels
  final p0 = image.getPixel(0, 0);
  print('Pixel at (0,0): r=${p0.r}, g=${p0.g}, b=${p0.b}, a=${p0.a}');
  
  final pCenter = image.getPixel(image.width ~/ 2, image.height ~/ 2);
  print('Pixel at center: r=${pCenter.r}, g=${pCenter.g}, b=${pCenter.b}, a=${pCenter.a}');
}
