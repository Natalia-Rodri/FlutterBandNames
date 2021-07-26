import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


enum ServerStatus{
  Online, 
  Offline, 
  Connecting
}

class SocketService with ChangeNotifier {

  late IO.Socket _socket;
  ServerStatus _serverStatus= ServerStatus.Connecting;
  IO.Socket get socket => this._socket;
  
  SocketService(){
    this._initConfig();
  }

  get emit => this._socket.emit;
  get off => this._socket.off;

  void _initConfig(){
    this._socket = IO.io('http://localhost:3000',{
      'transports': ['websocket'],
      'autoConnect': true
    });

    _socket.onConnect((_) {
      _serverStatus=ServerStatus.Online;
      this.notifyListeners();
    });

    _socket.onDisconnect((_){
      _serverStatus=ServerStatus.Offline;
      this.notifyListeners();
    });

    _socket.on("nuevo-mensaje", ( payload ) {
      print( "nuevo-mensaje:");
      print("Nombre: " +payload["nombre"]);
      print("Mensaje: " +payload["mensaje"]);
      print( payload.containsKey("mensaje2") ? payload["mensaje2"] : "No hay" );
      //Si esperamos una propiedad y no ha venido, hay que manejarlo porque peta estrepitosamente 

    });

  }

  ServerStatus get serverStatus => this._serverStatus;
  

}