

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected async{
   if( await connectionChecker.checkConnectivity() == ConnectivityResult.none){
    return false;
   }else{
    return true;
   }
  } 
}
