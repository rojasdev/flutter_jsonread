import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MenuItem {
  final String id;
  final String name;
  final String price;
  final String category;
  final String imageUrl;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Image and JSON Loading Demo',
      home: ImageAndJsonLoadingDemo(),
    );
  }
}

class ImageAndJsonLoadingDemo extends StatefulWidget {
  const ImageAndJsonLoadingDemo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImageAndJsonLoadingDemoState createState() =>
      _ImageAndJsonLoadingDemoState();
}

class _ImageAndJsonLoadingDemoState extends State<ImageAndJsonLoadingDemo> {
  late Future<List<MenuItem>> _menuItems;

  @override
  void initState() {
    super.initState();
    _menuItems = _fetchMenuItems();
  }

  Future<List<MenuItem>> _fetchMenuItems() async {
    final response = await http
        .get(Uri.parse('https://devlab.helioho.st/serve/readfoods.php'));
    if (response.statusCode == 200) {
      Iterable data = json.decode(response.body);
      return List<MenuItem>.from(data.map((model) => MenuItem(
            id: model['id'],
            name: model['name'],
            price: model['price'],
            category: model['category'],
            imageUrl:
                'https://raw.githubusercontent.com/rojasdev/assets/main/beach.png', // Assuming image URL follows a pattern
          )));
    } else {
      throw Exception('Failed to load menu items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FutureBuilder<List<MenuItem>>(
          future: _menuItems,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Show loading indicator while fetching data
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Image.network(
                      snapshot.data![index].imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(snapshot.data![index].name),
                    subtitle: Text(
                        'Price: Php ${snapshot.data![index].price}\nCategory: ${snapshot.data![index].category}'),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
