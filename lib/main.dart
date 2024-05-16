import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:radar/environment/env.dart';
import 'package:radar/model_views/radar_model_view.dart';
import 'package:radar/mqtt/client_subscriber.dart';
import 'package:radar/views/radar_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async{



  WidgetsFlutterBinding.ensureInitialized();

  
  GetIt.instance.registerSingleton<ENV>(ENV());
  GetIt.instance.registerSingleton<RadarModelView>(RadarModelView());
  GetIt.instance.registerSingleton<ClientSubscriber>(ClientSubscriber());

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey("tower_score")){

      GetIt.instance.get<RadarModelView>().changeTowerScore(prefs.getInt("tower_score")!);
      


    }
    else {
      prefs.setInt("tower_score", 0);

    }

    if(prefs.containsKey("tank_score")){
      GetIt.instance.get<RadarModelView>().changeTankScore(prefs.getInt("tank_score")!);

    }
    else {
      prefs.setInt("tank_score",0);


    }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
Widget build(BuildContext context) {
  return MaterialApp(
    title: "radar",
    initialRoute: "/radar",
    



    routes: {

      "/radar":(context)=>MyHomePage()
    },
  );
}

}