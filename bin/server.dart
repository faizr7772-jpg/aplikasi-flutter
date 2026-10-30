import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

void main() async {
  final router = Router();

  router.get('/api/laptops', (Request request) {
    final data = {
      "products": [
        {
          "id": 1,
          "title": "MacBook Pro 14",
          "brand": "Apple",
          "price": 1999,
          "rating": 4.8,
          "stock": 10,
          "thumbnail": "https://cdn.dummyjson.com/products/images/laptops/Apple%20MacBook%20Pro%2014%20Inch%20Space%20Grey/thumbnail.png",
          "description": "Supercharged by M2 Pro atau M2 Max. Layar Liquid Retina XDR yang menakjubkan."
        },
        {
          "id": 2,
          "title": "Asus ROG Zephyrus",
          "brand": "Asus",
          "price": 1499,
          "rating": 4.7,
          "stock": 5,
          "thumbnail": "https://cdn.dummyjson.com/products/images/laptops/Asus%20Zenbook%20Pro%20Dual%20Screen%20Laptop/thumbnail.png",
          "description": "Laptop gaming kencang dengan desain yang elegan dan ringan."
        }
      ]
    };

    return Response.ok(
      jsonEncode(data),
      headers: {'content-type': 'application/json', 'Access-Control-Allow-Origin': '*'},
    );
  });

  final server = await io.serve(router.call, InternetAddress.anyIPv4, 8080);
  print('Web Service berjalan di port ${server.port}');
}