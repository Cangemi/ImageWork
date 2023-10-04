import 'dart:async';
//import 'dart:html';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver_v3/image_gallery_saver.dart';

class ImageWork {
  ImageWork();

  Future<void> saveImage(ImageProvider image) async {
    try {
      final img = await _imageToUiImage(Image(
        image: image,
      ));
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/newImage.png');
      await file.writeAsBytes(Uint8List.view(bytes!.buffer));

      // Salva a imagem na galeria
      final result =
          await ImageGallerySaver.saveImage(Uint8List.view(bytes.buffer));

      print('Imagem salva em: ${file.path}');
    } catch (e) {
      print('Erro ao salvar a imagem: $e');
    }
  }

  Future<Image> loadImage(String path) async {
    final bytes = await File(path).readAsBytes();
    return Image.memory(bytes);
  }

  Future<ui.Image> _imageToUiImage(Image image) async {
    final completer = Completer<ui.Image>();
    image.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener(
            (info, _) => completer.complete(info.image),
          ),
        );
    final uiImage = await completer.future;
    return uiImage;
  }

  Future<ImageProvider<Object>> makeImage(Image image1, Image image2) async {
    final recorder = ui.PictureRecorder();

    final img1 = await _imageToUiImage(image1);
    final img2 = await _imageToUiImage(image2);

    // Desenha as duas imagens em um canvas
    final canvas = Canvas(recorder);
    canvas.drawImage(img1, Offset.zero, Paint());
    canvas.drawImage(img2, Offset(img1.width.toDouble(), 0), Paint());

    // Cria uma nova imagem a partir do `PictureRecorder`
    final picture = recorder.endRecording();
    final img = await picture.toImage((img1.width + img2.width), img1.height);

    // Salva a nova imagem em um arquivo
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

    ImageProvider imageProvider = MemoryImage(Uint8List.view(bytes!.buffer));

    return imageProvider;
  }

  Future<ImageProvider<Object>> toGrayScale(Image image) async {
    // Converte a imagem do tipo Image para o tipo ui.Image
    final uiImage = await _imageToUiImage(image);

    // Cria um novo objeto de imagem do tipo ui.Image com a mesma dimensão da imagem original
    final recorder = ui.PictureRecorder();
    //final grayScaleImage = ui.Image(uiImage.width, uiImage.height);

    // Desenha a imagem original em um canvas, aplicando o filtro de tons de cinza
    final canvas = Canvas(recorder);

    final paint = Paint()
      ..colorFilter = const ColorFilter.matrix(<double>[
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ]);
    canvas.drawImage(uiImage, Offset.zero, paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(uiImage.width, uiImage.height);

    // Salva a nova imagem em um arquivo
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

    ImageProvider imageProvider = MemoryImage(Uint8List.view(bytes!.buffer));

    return imageProvider;
  }

  Future<ImageProvider<Object>> toBinary(Image image) async {
    final uiImage = await _imageToUiImage(image);

    // Crie um PictureRecorder para desenhar a nova imagem
    final recorder = ui.PictureRecorder();

    // Obtenha a largura e a altura da imagem
    final width = uiImage.width;
    final height = uiImage.height;

    // Crie um Canvas para desenhar a nova imagem
    final canvas = Canvas(recorder);

    // Desenhe a imagem original no Canvas
    canvas.drawImage(uiImage, Offset.zero, Paint());

    // Obtenha os pixels da imagem
    final imgData = await uiImage.toByteData();

    // Percorra todos os pixels da imagem
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Obtenha a cor do pixel
        final pixelOffset = (y * width + x) * 4;
        if (pixelOffset + 3 >= imgData!.lengthInBytes) {
          // pixelOffset está fora dos limites de imgData, pule para o próximo pixel
          continue;
        }
        final r = imgData.getUint8(pixelOffset);
        final g = imgData.getUint8(pixelOffset + 1);
        final b = imgData.getUint8(pixelOffset + 2);

        // Calcule a média dos valores de vermelho, verde e azul do pixel
        final average = (0.299 * r + 0.587 * g + 0.114 * b).toInt();

        // Defina a cor do pixel no Canvas como preto ou branco, dependendo do valor médio
        if (average < 128) {
          //canvas.drawColor(Color(0xff000000), BlendMode.src);
          canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1.0, 1.0),
              Paint()..color = Color(0xff000000));
        } else {
          //canvas.drawColor(Color(0xffffffff), BlendMode.src);
          canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1.0, 1.0),
              Paint()..color = Color(0xffffffff));
        }
      }
    }

    // Crie uma nova imagem a partir do PictureRecorder
    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);

    // Salva a nova imagem em um arquivo
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);

    ImageProvider imageProvider = MemoryImage(Uint8List.view(bytes!.buffer));

    return imageProvider;
  }
}
