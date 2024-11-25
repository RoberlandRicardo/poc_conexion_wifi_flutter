// ignore_for_file: avoid_print

import 'dart:math';
import 'dart:typed_data';

import 'package:location/location.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_test/model/obj_wifi.dart';
import 'package:wifi_test/pages/send_mensage.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Nearby Connections example app'),
        ),
        body: const Body(),
      ),
    );
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _MyBodyState();
}

class _MyBodyState extends State<Body> {

  TextEditingController nameInput = TextEditingController();
  final Strategy strategy = Strategy.P2P_STAR;
  List<ObjWifi> listWifiDiscovered = [];
  bool adversiting = false;
  bool discovering = false;

  @override
  void initState() {
    Nearby().stopAdvertising();
    Nearby().stopDiscovery();
    callPermissions();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void callPermissions() async {
    await Permission.nearbyWifiDevices.request();
    await Permission.location.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothAdvertise.request();
  }

  void startDiscovering() async {
    try {
      bool a = await Nearby().startDiscovery(
          nameInput.text,
          strategy,
          onEndpointFound: (String id,String username, String serviceId) {
            print("Endpoint found: $username");
            Nearby().disconnectFromEndpoint(id);
            setState(() {
              listWifiDiscovered.add(
                ObjWifi(id: id, username: username, serviceId: serviceId)
              );
            });
            
          },
          onEndpointLost: (String? id) {
          },
          serviceId: "com.imd.wifi_test",
      );
      setState(() {
        discovering = a;
      });
    } catch (e) {
    }
  }

  void startAdvertising() async {
    print("Adversiting");
    try {
      bool a = await Nearby().startAdvertising(
        nameInput.text,
        strategy,
        onConnectionInitiated: (String id,ConnectionInfo info) async {
          print("Conexão encontrada");
          await showModalBottomSheet(
            context: context,
            builder: (builder) {
              return Center(
                child: Column(
                  children: <Widget>[
                    Text("id: $id"),
                    Text("Token: ${info.authenticationToken}"),
                    Text("Name${info.endpointName}"),
                    Text("Incoming: ${info.isIncomingConnection}"),
                    ElevatedButton(
                      child: const Text("Accept Connection"),
                      onPressed: () async  {
                        Navigator.pop(context);
                        bool a = await Nearby().acceptConnection(
                          id,
                          onPayLoadRecieved: (endid, payload) {
                            print("Recebendo dados");
                            print(payload.type.toString());
                            if (payload.type == PayloadType.BYTES) {
                              String str = String.fromCharCodes(payload.bytes!);
                              print("$endid: $str");
                            } else if (payload.type == PayloadType.FILE) {
                            }
                          },
                          onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                            if (payloadTransferUpdate.status ==
                                PayloadStatus.IN_PROGRESS) {
                              print(payloadTransferUpdate.bytesTransferred);
                            } else if (payloadTransferUpdate.status ==
                                PayloadStatus.FAILURE) {
                              print("failed");
                            } else if (payloadTransferUpdate.status ==
                                PayloadStatus.SUCCESS) {
                            }
                          },
                        );
                        if (a) await Nearby().sendBytesPayload(id, Uint8List.fromList("Testando".codeUnits));
                      },
                    ),
                    ElevatedButton(
                      child: const Text("Reject Connection"),
                      onPressed: () async {
                        Navigator.pop(context);
                        try {
                          await Nearby().rejectConnection(id);
                        } catch (e) {

                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        onConnectionResult: (String id,Status status) {
          print("Result ${status.toString()}");
        },
        onDisconnected: (String id) {
        },
        serviceId: "com.imd.wifi_test",
      );

      setState(() {
        adversiting = a;
      });
    } catch (exception) {
    }
  }

  void tryConnect(String id ) async {
    try{
      await Nearby().requestConnection(
          nameInput.text,
          id,
          onConnectionInitiated: (id, info) async {
            await showModalBottomSheet(
              context: context,
              builder: (builder) {
                return Center(
                  child: Column(
                    children: <Widget>[
                      Text("id: $id"),
                      Text("Token: ${info.authenticationToken}"),
                      Text("Name${info.endpointName}"),
                      Text("Incoming: ${info.isIncomingConnection}"),
                      ElevatedButton(
                        child: const Text("Accept Connection"),
                        onPressed: () async  {
                          Navigator.pop(context);
                          bool a = await Nearby().acceptConnection(
                            id,
                            onPayLoadRecieved: (endid, payload) {
                              print("Recebendo dados");
                              if (payload.type == PayloadType.BYTES) {
                                String str = String.fromCharCodes(payload.bytes!);
                                print("$endid: $str");
                              } else if (payload.type == PayloadType.FILE) {
                              }
                            },
                            onPayloadTransferUpdate: (endid, payloadTransferUpdate) {
                              print("Recebendo dados");
                              if (payloadTransferUpdate.status ==
                                  PayloadStatus.IN_PROGRESS) {
                                print(payloadTransferUpdate.bytesTransferred);
                              } else if (payloadTransferUpdate.status ==
                                  PayloadStatus.FAILURE) {
                                print("failed");
                              } else if (payloadTransferUpdate.status ==
                                  PayloadStatus.SUCCESS) {
                              }
                            },
                          );
                          if (a) await Nearby().sendBytesPayload(id, Uint8List.fromList("Testando".codeUnits));
                        },
                      ),
                      ElevatedButton(
                        child: const Text("Reject Connection"),
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            await Nearby().rejectConnection(id);
                          } catch (e) {

                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            );
            
          },
          onConnectionResult: (id, status) async {
            
            
          },
          onDisconnected: (id) {
          },
      );
    } catch(exception){
        // called if request was invalid
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextFormField(
            controller: nameInput,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 5.0),
              ),
              
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () {
              if (adversiting) {
                Nearby().stopAdvertising();
                setState(() {
                  adversiting = false;
                });
              } else {
                startAdvertising();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12
              ),
              decoration: BoxDecoration(
                color: adversiting ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Center(
                child: Text(
                  adversiting
                  ? "Para de anunciar"
                  : "Anunciar meu dispositivo",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          GestureDetector(
            onTap: () {
              if (discovering) {
                Nearby().stopDiscovery();
                setState(() {
                  discovering = false;
                });
              } else {
                startDiscovering();
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12
              ),
              decoration: BoxDecoration(
                color: discovering ? Colors.red : Colors.green,
                borderRadius: BorderRadius.circular(8)
              ),
              child: Center(
                child: Text( discovering
                  ? "Interromper busca"
                  : "Descobrir dispostivos",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: listWifiDiscovered.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8
                      ),
                      onTap: () => tryConnect(listWifiDiscovered[index].id),
                      title: Text(
                        listWifiDiscovered[index].username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      subtitle: Text(
                        listWifiDiscovered[index].id,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      tileColor: Colors.white60,
                    ),
                    const SizedBox(
                      height: 8,
                    )
                  ],
                );
              }
            ) 
          ),
        ],
      ),
    );
  } 

  
}