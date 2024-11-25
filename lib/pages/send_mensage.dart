
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:nearby_connections/nearby_connections.dart';

class SendMensage extends StatelessWidget {
  const SendMensage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {

    TextEditingController mensageInput = TextEditingController();

    void sendMensage() async {
      await Nearby().sendBytesPayload(id, Uint8List.fromList( mensageInput.text.codeUnits));
    }

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextFormField(
            controller: mensageInput,
            decoration: const InputDecoration(
              border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 5.0),
              ),
              
            ),
          ),
          const SizedBox(height: 8,),
          GestureDetector(
            onTap: () => sendMensage(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12
              ),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8)
              ),
              child: const Center(
                child: Text(
                  "Enviar mensagem",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}