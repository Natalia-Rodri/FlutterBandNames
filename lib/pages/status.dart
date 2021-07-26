import 'package:bandname/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class StatusPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final socketService = Provider.of<SocketService>(context);
    //socketService.socket.emit(event)

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("ServerStatus:"+ socketService.serverStatus.toString()),
          ],
        )
     ),
     floatingActionButton: FloatingActionButton(
       child: Icon(Icons.message),
       onPressed: (){
         socketService.emit("emitir-mensaje", {"nombre": "Flutter", "mensaje": "Hola desde Flutter"});
         //Emitir un mapa que tega el nombre y el mensaje hola desde flutter
       },
     ),
   );
  }
}