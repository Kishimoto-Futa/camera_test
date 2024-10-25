import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

// アプリのエントリーポイント
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CameraScreen(), // カメラスクリーンを表示
    );
  }
}

// カメラスクリーンの状態を管理するクラス
class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  // 画像ファイルの変数
  File? _imageFile;
  File? _compressedImageFile;
  String? _originalSize; // 元の画像サイズ
  String? _compressedSize; // 圧縮後の画像サイズ
  final ImagePicker _picker = ImagePicker(); // 画像ピッカーのインスタンス

  // 画像を撮影するメソッド
  Future<void> _takePicture() async {
    // 現在の画像データをクリア
    setState(() {
      _imageFile = null; // 元の画像ファイルをnullに設定
      _compressedImageFile = null; // 圧縮された画像ファイルをnullに設定
      _originalSize = null; // 元のサイズをnullに設定
      _compressedSize = null; // 圧縮サイズをnullに設定
    });

    try {
      // システムのカメラを開く
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        // 撮影された画像ファイルを取得
        _imageFile = File(pickedFile.path);

        // 元の画像サイズを取得
        _originalSize = _formatFileSize(_imageFile!.lengthSync());

        // 画像を圧縮して保存
        await _compressImage(_imageFile!);
      }
    } catch (e) {
      print(e); // エラーが発生した場合はコンソールに出力
    }

    setState(() {}); // 状態を更新してUIを再描画
  }

  // 画像を圧縮するメソッド
  Future<void> _compressImage(File imageFile) async {
    // 一時ディレクトリのパスを取得
    final dir = await getTemporaryDirectory();
    final targetPath = '${dir.path}/compressed_image.jpg'; // 圧縮後の画像ファイルの保存先

    // 画像を読み込んで圧縮
    final image = img.decodeImage(imageFile.readAsBytesSync())!; // 画像をデコード
    final compressedImageBytes = img.encodeJpg(image, quality: 50); // 圧縮率を50%に設定

    // 圧縮後のファイルを保存
    _compressedImageFile = await File(targetPath).writeAsBytes(Uint8List.fromList(compressedImageBytes));

    // 圧縮後の画像サイズを取得
    _compressedSize = _formatFileSize(_compressedImageFile!.lengthSync());
  }

  // ファイルサイズをフォーマットするメソッド
  String _formatFileSize(int sizeInBytes) {
    // サイズが1未満の場合は切り捨て
    return (sizeInBytes < 1024)
        ? '0 KB' // 1KB未満の場合は0KBと表示
        : '${(sizeInBytes / 1024).floor()} KB'; // KB単位で表示
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Test'), // アプリバーのタイトル
      ),
      body: SingleChildScrollView( // スクロール可能なビューを作成
        child: Column(
          children: [
            // 元の画像ファイルが存在する場合
            if (_imageFile != null)
              Column(
                children: [
                  Text('圧縮前 サイズ: $_originalSize'), // 元の画像サイズを表示
                  Image.file(_imageFile!), // 元の画像を表示
                ],
              ),
            SizedBox(height: 10), // 空白スペース
            // 圧縮された画像ファイルが存在する場合
            if (_compressedImageFile != null)
              Column(
                children: [
                  Text('圧縮後: サイズ: $_compressedSize'), // 圧縮後の画像サイズを表示
                  Image.file(_compressedImageFile!), // 圧縮された画像を表示
                ],
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicture, // FABを押したときに画像撮影メソッドを呼び出す
        child: Icon(Icons.camera_alt), // FABのアイコン
      ),
    );
  }
}
