import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:radar/environment/env.dart';
import 'package:radar/model_views/radar_model_view.dart';

class ClientSubscriber {

  final MqttServerClient client=MqttServerClient(GetIt.instance.get<ENV>().broker, GetIt.instance.get<ENV>().clientIdentifier);


  ClientSubscriber(){

    client.port=GetIt.instance.get<ENV>().port;
    client.logging(on: true);
      client.onConnected = () {
    print('Connected');
  };

    client.onDisconnected = () {
    print('Disconnected');
  };

    client.onSubscribed = (String topic) {
    print('Subscribed topic: $topic');
  };

  connectAndSubscribeAndListen();

  
 



  }

  Future<void> connectAndSubscribeAndListen() async{

    final MqttConnectMessage connMess = MqttConnectMessage()
      .withClientIdentifier(GetIt.instance.get<ENV>().clientIdentifier)
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  print('MQTT client connecting....');
  client.connectionMessage = connMess;

  try {
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  if (client.connectionStatus!.state != MqttConnectionState.connected) {
    print('MQTT client connection failed - disconnecting, status is ${client.connectionStatus}');
    client.disconnect();
  }

     String subscriptionTopic=GetIt.instance.get<ENV>().subscriptionTopic;
     String subscriptionTopicTwo=GetIt.instance.get<ENV>().subscriptionTopictwo;

     String subscriptionTopicThree=GetIt.instance.get<ENV>().subscriptionTopicthree;
     
     client.subscribe(subscriptionTopic, MqttQos.atLeastOnce);
     client.subscribe(subscriptionTopicTwo, MqttQos.atLeastOnce);
     client.subscribe(subscriptionTopicThree, MqttQos.atLeastOnce);

client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
  final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
  final String payloadString = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

  final String topic=c[0].topic;

  print('Received message: topic is <${c[0].topic}>, payload is <-- $payloadString -->');
  
  try {
    final dynamic decodedJson = json.decode(payloadString);
    print('Decoded JSON: $decodedJson');
    if(topic==subscriptionTopic){
        GetIt.instance.get<RadarModelView>().changeDistanceAndAngle(decodedJson['distance'].toDouble(), decodedJson['angle'].toDouble());
     GetIt.instance.get<RadarModelView>().updatePointPosition();
     print("hey");


    }

    if(topic==subscriptionTopicTwo){
      
      

      if(decodedJson['key']=="tower"){
       
        GetIt.instance.get<RadarModelView>().incrementTankScore();


      }

      if(decodedJson['key']=="car"){

        GetIt.instance.get<RadarModelView>().incrementRadarScore();


      }



    }

    if(topic==subscriptionTopicThree){

      
    }
  

  } catch (e) {
    print('Error decoding JSON: $e');
  }
});



  }

 



}


