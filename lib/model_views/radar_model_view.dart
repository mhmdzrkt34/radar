import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadarModelView extends ChangeNotifier {

  late AnimationController _controller;
  late List<double>? positions=null;
  late double deviceWidth;
  late double deviceHeight;
  late bool alert=false;

  int towerScore=0;
  int tankScore=0;
   final player = AudioPlayer();
  

    double? angle = null;
  double? distance = null; 







  RadarModelView(){
    
  }

  void getScreenSize(double width,double height){
    deviceHeight = height;
    deviceWidth= width;
  }

  //for testing
Future<void> updatePointPosition() async{
  double angleInRadians = angle! * pi / 180.0;
  double centerX = deviceWidth*0.8 / 2;
  double centerY = deviceWidth*0.8 / 2;

  // Scaling factor for distance to keep it within bounds, adjust as necessary
  double scale = min(deviceWidth*0.8, deviceWidth*0.8) / 2 * 0.8; // 80% of half the size of the radar
  double scaledDistance = min(distance!, scale);

  double x = centerX + scaledDistance * cos(angleInRadians);
  double y = centerY + scaledDistance * sin(angleInRadians);

  // Clamping x and y to ensure they are within the viewable area
  x = x.clamp(0, deviceWidth*0.8);
  y = y.clamp(0, deviceWidth*0.8);

  // Debug output to check coordinates
  print("Adjusted x: $x, Adjusted y: $y, centerX: $centerX, centerY: $centerY");

  positions = List.from([y, 0.0, 0.0, x]);
  notifyListeners();

  if(alert==false){

  }
  else {
  await player.play(AssetSource("sounds/sonar-ping-sound-effect.mp3"));
  }
}

void changeDistanceAndAngle(double distanceParameter, double angleParameter){
  distance=distanceParameter;
  angle=angleParameter+270;
  

}
void changeAlert(){
  alert=!alert;
  notifyListeners();
}

void incrementRadarScore() async{

  towerScore=towerScore+1;
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("tower_score",towerScore);
  notifyListeners();







}

void incrementTankScore() async{





  tankScore=tankScore+1;
      SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setInt("tank_score",tankScore);
  notifyListeners();
}

void changeTankScore(int score){
  tankScore=score;
}

void changeTowerScore(int score){


  towerScore=score;
}



}