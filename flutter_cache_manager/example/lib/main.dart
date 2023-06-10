import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:example/plugin_example/download_page.dart';
import 'package:example/plugin_example/floating_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logging/logging.dart';

void main() {
  runApp(BaseflowPluginExample(
    pluginName: 'Flutter Cache Manager',
    githubURL: 'https://github.com/Baseflow/flutter_cache_manager',
    pubDevURL: 'https://pub.dev/packages/flutter_cache_manager',
    pages: [CacheManagerPage.createPage()],
  ));
  Logger.root.level = Level.FINE;
  cacheLogger.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });
}

const url = 'https://blurha.sh/assets/images/img1.jpg';

/// Example [Widget] showing the functionalities of flutter_cache_manager
class CacheManagerPage extends StatefulWidget {
  const CacheManagerPage({super.key});

  static ExamplePage createPage() {
    return ExamplePage(Icons.save_alt, (context) => const CacheManagerPage());
  }

  @override
  State<CacheManagerPage> createState() => _CacheManagerPageState();
}

class _CacheManagerPageState extends State<CacheManagerPage> {
  Stream<FileResponse>? fileStream;

  void _downloadFile() {
    setState(() {
      fileStream = DefaultCacheManager().getFileStream(url, withProgress: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (fileStream == null) {
      return Scaffold(
        appBar: null,
        body: const ListTile(
            title: Text('Tap the floating action button to download.')),
        floatingActionButton: Fab(
          downloadFile: _downloadFile,
        ),
      );
    }
    return DownloadPage(
      fileStream: fileStream!,
      downloadFile: _downloadFile,
      clearCache: _clearCache,
      removeFile: _removeFile,
    );
  }

  void _clearCache() {
    DefaultCacheManager().emptyCache();
    setState(() {
      fileStream = null;
    });
  }

  void _removeFile() {
    DefaultCacheManager().removeFile(url).then((value) {
      Logger.root.info('File removed');
    }).onError((dynamic error, stackTrace) {
      Logger.root.error(error);
    });
    setState(() {
      fileStream = null;
    });
  }
}
