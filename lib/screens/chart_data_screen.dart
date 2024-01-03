import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
/// Dart imports
import 'dart:async';


class ChartData extends StatefulWidget {

    const ChartData({Key? key}) : super(key: key);

  @override
  State<ChartData> createState() => _ChartDataState();
}
var lastData;
DatabaseReference starCountRef = FirebaseDatabase.instance.ref('info');
class _ChartDataState extends State<ChartData> {
  Timer? timer;
  List<MyChartData>? chartData=[];
  late int count;
  ChartSeriesController? _chartSeriesController;
  List<String> selectMaxValue =["300","400","500","600","800","1000"];
  List<String> selectMaxInterval =["10","50","100","150","200","300"];
bool isCardView=true;
bool isLoading=true;
  List myOrderData=[];
  int startMAXValue=2;
  int startMAXInter=2;

  @override
  void dispose() {
    timer?.cancel();
    chartData!.clear();
    _chartSeriesController = null;
    super.dispose();
  }

  String sensorType="Smk";
  @override
  void initState() {
    count = 19;

   
    initData(sensorType);

    super.initState();
  }


  changeSensorType(type){
    initData(type);




    setState(() {
      sensorType=type;
    });


  }

  initData(String type){
    chartData!.clear();

    myOrderData.clear();
    starCountRef.get().then((value) {

    Map data = value.value as Map;


        myOrderData = data.entries.toList();

    myOrderData.sort((a, b) {
      return a.key.compareTo(b.key);
    }); // inplace sort
    // setState(() {
    //   lastData = myOrderData.last;
    // });

    setState(() {
      lastData = myOrderData.last;
    });

    for (var element in myOrderData) {


      try{

        chartData?.add(MyChartData(date: readTimestamp(int.parse( element.key)).toString(),value: int.parse(element.value[type])));



      }catch(e){
        print("erorr");
      }
      setState(() {
        isLoading=false;
      });
    }

  });

    //  starCountRef.onValue.listen((DatabaseEvent event) {
    //   // Map data = event.snapshot.value as Map;
    //   //
    //   //
    //   // myOrderData = data.entries.toList();
    //   //
    //   // myOrderData.sort((a, b) {
    //   //   return a.key.compareTo(b.key);
    //   // }); // inplace sort
    //   // // setState(() {
    //   // //   lastData = myOrderData.last;
    //   // // });
    //   //
    //   // setState(() {
    //   //   lastData = myOrderData.last;
    //   // });
    //   //
    //   // for (var element in myOrderData) {
    //   //
    //   //
    //   //   chartData?.add(MyChartData(date: readTimestamp(int.parse( element.key)).toString(),value: int.parse(element.value[type])));
    //   //
    //   //   setState(() {
    //   //     isLoading=false;
    //   //   });
    //   // }
    //   //
    //
    // }) ;

  }
  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('yyyy-MM-dd-kk:mm');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = date.difference(now);
    var time = '';


      time = format.format(date);


    return time;
  }




  @override
  Widget build(BuildContext context) {
    // if(!isLoading){
    //   _updateDataSource(Timer(Duration(milliseconds: 900), () {
    //     setState(() {
    //
    //     });
    //   }),sensorType);
    // }

    return       isLoading? const Center(child: CircularProgressIndicator(),): SingleChildScrollView(
      child: Column(children: [

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextButton(onPressed: (){
              changeSensorType('Smk');
            }, child:   Text("Smk",style: TextStyle(color: sensorType=="Smk"?Colors.blue:Colors.black),)),
            TextButton(onPressed: (){
              changeSensorType('Gaz');
            }, child:   Text("Gaz",style: TextStyle(color:sensorType=="Gaz"?Colors.blue:Colors.black),)),
            TextButton(onPressed: (){
              changeSensorType('iTmp');
            }, child:   Text("iTmp",style: TextStyle(color:sensorType=="iTmp"?Colors.blue:Colors.black),)),
            TextButton(onPressed: (){
              changeSensorType('oTmp');
            }, child:   Text("oTmp",style: TextStyle(color:sensorType=="oTmp"?Colors.blue:Colors.black),)),
          ],
        ),
   Row(

     mainAxisAlignment: MainAxisAlignment.center,
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       DropdownButton<String>(
         icon: Row(children: const[
           Text("Max Value",style: TextStyle(color: Colors.black),),
           Icon(Icons.arrow_drop_down)
         ],),
         items: selectMaxValue.map((String value) {

           return DropdownMenuItem<String>(
             value: value,
             child: Text(value,style: const TextStyle(color: Colors.black),),
           );
         }).toList(),
         value: selectMaxValue[startMAXValue],
         onChanged: (value) {
           setState(() {
             print(value);
             startMAXValue=selectMaxValue.indexOf(value!);

           });
         },
       ),
       DropdownButton<String>(
         icon: Row(children: const[
           Text("Max interval",style: TextStyle(color: Colors.black),),
           Icon(Icons.arrow_drop_down)
         ],),
         items: selectMaxInterval.map((String value) {

           return DropdownMenuItem<String>(
             value: value,
             child: Text(value,style: const TextStyle(color: Colors.black),),
           );
         }).toList(),
         value: selectMaxInterval[startMAXInter],
         onChanged: (value) {
           setState(() {
             print(value);
             startMAXInter=selectMaxInterval.indexOf(value!);

           });
         },
       ),
     ],
   ),

        Center(child: _buildLiveLineChart(),)
      ],),
    );
  }

  /// Returns the realtime Cartesian line chart.
    _buildLiveLineChart() {

    return SfCartesianChart(
        plotAreaBorderWidth: 0,
        enableAxisAnimation: true,

        zoomPanBehavior: ZoomPanBehavior(



            enablePinching: true,
            // Enables the selection zooming
            enableSelectionZooming: true
        ),


        primaryXAxis:
        CategoryAxis(majorGridLines: const MajorGridLines(width: 1),


        ),
        primaryYAxis: CategoryAxis(
            axisLine: const AxisLine(width: 0),
            interval: double.tryParse(selectMaxInterval[startMAXInter].toString()),
            minimum: 0,
            maximum: double.tryParse(selectMaxValue[startMAXValue].toString()),

            majorTickLines: const MajorTickLines(size: 0)),

        series: <LineSeries<MyChartData, String>>[
          LineSeries<MyChartData, String>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },


            dataSource: chartData!,
            color: const Color.fromRGBO(192, 108, 132, 1),
            xValueMapper: (MyChartData sales, _) => sales.date,

              yValueMapper: (MyChartData sales, _) => sales.value,
            animationDuration: 0,


          )
        ]);
  }

  ///Continously updating the data source based on timer
  // void _updateDataSource(Timer timer,type) {
  //   if (isCardView != null) {
  //
  //
  //     chartData!.add(MyChartData(value: int.parse( lastData.value[type]) ,date: readTimestamp(int.parse( lastData.key)).toString()));
  //     if (chartData!.length == 100) {
  //       chartData!.removeAt(0);
  //
  //       _chartSeriesController?.updateDataSource(
  //         addedDataIndexes: <int>[chartData!.length - 1],
  //         removedDataIndexes: <int>[0],
  //       );
  //     } else {
  //       _chartSeriesController?.updateDataSource(
  //         addedDataIndexes: <int>[chartData!.length - 1],
  //       );
  //     }
  //     count = count + 1;
  //   }
  // }


}


class MyChartData {
  MyChartData({ required this.date,required this.value});
  final String date;
  final int value;
}