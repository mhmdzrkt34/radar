import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:radar/model_views/radar_model_view.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
 
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
 
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
 
class _MyHomePageState extends State<MyHomePage>
 
    with SingleTickerProviderStateMixin {
      late WebViewController _webviewcontroller;
      bool _isStreamAvailable=false;
          late double deviceHeight;
    late double deviceWidth;
  late AnimationController _controller;
  final String imageUrl =
      'https://cdn.picpng.com/radar/radar-blank-green-center-82191.png';
 
  @override
  void initState() {
_webviewcontroller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('http://172.16.128.248:5000/video_feed'))
          .then((_) {
        setState(() {
          _isStreamAvailable = true;
        });
      }).catchError((error) {
        setState(() {
          _isStreamAvailable = false;
          print('Error loading stream: $error');
        });
      });
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
    super.initState();
  }
 
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    deviceWidth=MediaQuery.of(context).size.width;
    deviceHeight=MediaQuery.of(context).size.height;
    GetIt.instance.get<RadarModelView>().getScreenSize(deviceWidth, deviceHeight);
   
 
    return MultiProvider(providers: [
      ChangeNotifierProvider.value(value: GetIt.instance.get<RadarModelView>(),)
    ],
    child: Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
 
          preferredSize: Size.fromHeight(50.0),
          child: Container(
            width: deviceWidth,
 
           
 
 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Row(children: [Icon(Icons.cell_tower,color: Colors.white,size: 40,),TowerScore()],),
           
            Row(children: [Icon(Icons.car_crash_sharp,color: Colors.white,size: 40,),TankScore()],)
            ],),
          ),
        ),
 
 
       
        backgroundColor: Colors.black,
        title:Container(width: deviceWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [ Container(
            alignment: Alignment.center,
            child: Text("Tower vs tank",style: TextStyle(color: Colors.white),),),
 
            Row(children: [Container(child: Text("alert",style: TextStyle(color: Colors.white),),),
 
            alertSwitch()
           
 
            ],)
           
     
            ],),
        ),
       
        ),
     
      backgroundColor: Colors.black,
      body: Center(child: Column(children: [
        Container(
          
          width: deviceWidth*0.8,
          height: 200,
          child: WebViewWidget(controller: _webviewcontroller)),

        
       
 
        Stack(children: [Container(
       
        width: deviceWidth*0.8,
        height: deviceWidth*0.8,
 
       
        decoration: BoxDecoration(
         
          image: DecorationImage(
           
              image: NetworkImage(imageUrl), fit: BoxFit.fill),
        ),
        child: RadarSignal(controller: _controller),
      ),
      pointWidget()
],)
      ],),)
    ));
  }
 
 
  Selector<RadarModelView,List<double>?> pointWidget(){
 
    return Selector<RadarModelView,List<double>?>(selector: (context,provider)=>provider.positions,
   
    shouldRebuild: (previous, next) => !identical(previous, next),
 
    builder: (context,value,child){
 
  if(value==null){
    return SizedBox();
  }
        return       Positioned(
 
        top: value![0],
        left: value![3],
       
        child:  Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white, // Center color
            Color.fromARGB(139, 35, 116, 56), // Outer ring color
          ],
          stops: [0.5, 1.0], // Stops for gradient effect, adjust as needed
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withAlpha(150), // Glow color
            blurRadius: 10, // Blur effect
            spreadRadius: 2, // Spread effect
          ),
        ],
      ),
    ));
    },
    );
  }
 
 
 
  Selector<RadarModelView,bool> alertSwitch(){
 
 
    return Selector<RadarModelView,bool>(selector: (context,provider)=>provider.alert,
    shouldRebuild: (previous,next)=>!identical(previous, next),
 
    builder: (context,value,child){
     return                    Switch(
                    activeColor: Colors.green,
                    value: value, onChanged: (value){
                      GetIt.instance.get<RadarModelView>().changeAlert();
 
 
 
            });
 
 
    },
    );
  }
 
  Selector<RadarModelView,int> TowerScore(){
 
    return Selector<RadarModelView,int>(selector: (context,provider)=>provider.towerScore,
 
    shouldRebuild: (previous,next)=>!identical(previous, next),
 
    builder: (context,value,child){
 
      return  Container(child: Text(value.toString(),style: TextStyle(color: Colors.white),),);
    },
   
    );
  }
 
  Selector<RadarModelView,int> TankScore(){
 
    return Selector<RadarModelView,int>(selector: (context,provider)=>provider.tankScore,
 
    shouldRebuild: (previous,next)=>!identical(previous, next),
 
    builder: (context,value,child){
 
      return  Container(child: Text(value.toString(),style: TextStyle(color: Colors.white),),);
    },
   
    );
  }

  }
 
 
 
class RadarSignal extends StatelessWidget {
  const RadarSignal({
    super.key,
    required AnimationController controller,
  }) : _controller = controller;
 
  final AnimationController _controller;
 
  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween(begin: 0.0, end: 4.0).animate(_controller),
      child: Container(
        decoration: const BoxDecoration(
          gradient: SweepGradient(
            center: FractionalOffset.center,
            colors: <Color>[
              Colors.transparent,
              Color(0xFF34A853),
              Colors.transparent,
            ],
            stops: <double>[0.20, 0.25, 0.20],
          ),
        ),
      ),
    );
  }
 
 
 
 
 
  }
 
 