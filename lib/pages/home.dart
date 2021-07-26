import 'package:bandname/models/band.dart';
import 'package:bandname/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket.on("active-bands", _handleActiveBands);

    super.initState();
  }

  _handleActiveBands( dynamic payload ){
    this.bands= (payload as List).map((band) => Band.fromMap(band)).toList();
    setState((){});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.off("active-bands");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          Container(
            margin: EdgeInsets.only( right: 10 ),
            child: 
              socketService.serverStatus==ServerStatus.Connecting ?
              Icon( Icons.check_circle, color: Colors.blueAccent )
              :
              socketService.serverStatus==ServerStatus.Offline ?
              Icon( Icons.offline_bolt, color: Colors.red )
              :
              Icon( Icons.check_circle, color: Colors.green )


          )
        ],
        title: Text("BandNames", style: TextStyle( color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          _showGraph(),
          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, index) =>  _bandTile(bands[index])
            ),
          )
        ],
      ), 
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand
      ),
   );
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
        key: Key(band.id),
        direction: DismissDirection.startToEnd,
        onDismissed: (_) => socketService.emit("remove-band", { "id": band.id }),
        background: Container(
              padding: EdgeInsets.only(left: 8.0),
              color: Colors.red,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.delete, color: Colors.white,)
            ),  
        ),
        child: ListTile(
          leading: CircleAvatar(
            child: Text( band.name, style: TextStyle(fontSize: 8),),
            backgroundColor: Colors.blue[100],
          ),
          title: Text(band.name),
          trailing: Text(" ${ band.votes } ", style: TextStyle(fontSize: 20),),
          onTap: () => socketService.emit("vote-band", { "id": band.id }),
        ),
    );
  }

  addNewBand(){
    final textController= new TextEditingController();

    return showDialog(
      context: context,
      builder: ( _ ) => AlertDialog(
          title: Text("New band name:"),
          content: TextField(
            controller: textController,
          ),
          actions: [
            MaterialButton(
              child: Text("Add"),
              elevation: 5,
              textColor: Colors.blue,
              onPressed: () => addBandToList (textController.text) 
            )
          ],
        )
    );
  }

  addBandToList(String name){
    final socketService = Provider.of<SocketService>(context, listen: false);

    if(name.length > 1){
      socketService.emit("add-band", { "name": name });
    }

    Navigator.pop(context);
  }

  //Mostrar gráfica
  _showGraph(){
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {dataMap.putIfAbsent(band.name, () => band.votes.toDouble());});
  return Container(
    padding: EdgeInsets.only(top: 15),
    height: 200,
    width: double.infinity,
    child: PieChart(
      dataMap: dataMap,
      animationDuration: Duration(milliseconds: 800),
      chartLegendSpacing: 32,
      chartRadius: MediaQuery.of(context).size.width / 3.2,
      initialAngleInDegree: 0,
      chartType: ChartType.ring,
      ringStrokeWidth: 32,
      centerText: "KPOP",
      legendOptions: LegendOptions(
        showLegendsInRow: false,
        legendPosition: LegendPosition.right,
        showLegends: true,
        legendShape: BoxShape.circle,
        legendTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      chartValuesOptions: ChartValuesOptions(
        showChartValueBackground: true,
        showChartValues: true,
        showChartValuesInPercentage: true,
        showChartValuesOutside: false,
        decimalPlaces: 1,
      ),)
    ) ;

  }
}