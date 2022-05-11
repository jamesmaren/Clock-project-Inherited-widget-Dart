import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      //inject Apiprovidr in main()
      home: ApiProvider(api: Api(), child: const MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
//class ApiProvider extends inheritedwidget

class ApiProvider extends InheritedWidget {
  final Api api;
  final String uuid;

  ApiProvider({
    Key? key,
    required this.api,
    required Widget child,
  })  : uuid = const Uuid().v4(),
        super(
          key: key,
          child: child,
        );

  //when will this widget be replaced
  @override
  bool updateShouldNotify(covariant ApiProvider oldWidget) {
    return uuid != oldWidget.uuid;
  }

  //a way for dependans to get  an instance
  static ApiProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ApiProvider>()!;
  }
}

class _MyAppState extends State<MyApp> {
  //add ValueKey<string> to your HomePage for DateTimeWidget
  ValueKey _textKey = const ValueKey<String?>(null);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(ApiProvider.of(context).api.dateAndTime ?? ''),
        ),
        body: GestureDetector(
          //in homepage upon onTap() call getDateAndTime
          onTap: () async {
            final api = ApiProvider.of(context).api;
            final dateAndTime = await api.getDateAndTime();

            // Upon onTap(). we need to change _textkey to tell flutter to update our DateTimeWidget
            setState(() {
              _textKey = ValueKey(dateAndTime);
            });
          },
          child: SizedBox.expand(
            child: Container(
              color: Colors.white,
              child: DateTimeWidget(key: _textKey),
            ),
          ),
        ));
  }
}

class DateTimeWidget extends StatelessWidget {
  const DateTimeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get ApiProvoder in DateTimeWidget and return Text()
    final api = ApiProvider.of(context).api;
    return Text(
      api.dateAndTime ?? 'Tap on screen to fetch date and time',
    );
  }
}

class Api {
  String? dateAndTime;
  Future<String> getDateAndTime() {
    return Future.delayed(
      const Duration(seconds: 1),
      () => DateTime.now().toIso8601String(),
    ).then((value) {
      dateAndTime = value;
      return value;
    });
  }
}
