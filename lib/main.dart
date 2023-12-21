import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';

void main() {
  _launchApp();
}

Future<void> _launchApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Remote Config Fetch Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, RemoteConfigValue>? _config;
  Duration? _loadingTime;

  @override
  void initState() {
    _loadRemoteConfig();
    super.initState();
  }

  void _loadRemoteConfig() async {
    final start = DateTime.now();
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 2),
      ),
    );
    await FirebaseRemoteConfig.instance.fetchAndActivate();
    final config = FirebaseRemoteConfig.instance.getAll();
    setState(() {
      _config = config;
      _loadingTime = DateTime.now().difference(start);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _config
                      ?.map((key, value) => MapEntry(key, value.asString()))
                      .toString() ??
                  'Loading...',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (_loadingTime != null) ...[
              const SizedBox(height: 16),
              Text('Loaded in ${_loadingTime!.inSeconds} seconds')
            ]
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
