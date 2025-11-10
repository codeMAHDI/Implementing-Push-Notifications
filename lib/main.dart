import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
class NotificationState {
  final String deviceToken;
  final String message;

  NotificationState({required this.deviceToken, required this.message});
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationState(deviceToken: "", message: ""));
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> getDeviceToken() async {
    String? token = await messaging.getToken();
    emit(NotificationState(
        deviceToken: token ?? "No Token", message: state.message));
  }

  void handleForegroundMessage(RemoteMessage message) {
    emit(NotificationState(
        deviceToken: state.deviceToken,
        message: message.notification?.title ?? "No title Found"));
  }

  void handleNotificationOpened(RemoteMessage message) {
    emit(NotificationState(
        deviceToken: state.deviceToken, message: "Notification Clicked"));
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background Msg Manager ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => NotificationCubit(),
        child: MaterialApp(
          title: 'Flutter Demo',
          home: MyHomePage(),
        ));
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    context.read<NotificationCubit>().getDeviceToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      context.read<NotificationCubit>().handleForegroundMessage(message);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      context.read<NotificationCubit>().handleNotificationOpened(message);
    });
    return Scaffold(
        appBar: AppBar(
          title: Text("This is FCM"),
        ),
        body: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Device Token: ${state.deviceToken} "),
                const SizedBox(
                  height: 20,
                ),
                Text("Notification Msg:${state.message} "),
              ],
            ),
          );
        }));
  }
}
