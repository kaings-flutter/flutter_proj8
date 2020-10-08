import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // (optional) using prefix `http`
import 'dart:convert'; // enable json.encode or decode

import 'product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  // moved all dummy items here since this the Products state is managed here
  // List<Product> _items = [
  //   Product(
  //     id: 'p1',
  //     title: 'Red Shirt',
  //     description: 'A red shirt - it is pretty red!',
  //     price: 29.99,
  //     imageUrl:
  //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  //   ),
  //   Product(
  //     id: 'p2',
  //     title: 'Trousers',
  //     description: 'A nice pair of trousers.',
  //     price: 59.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  //   ),
  //   Product(
  //     id: 'p3',
  //     title: 'Yellow Scarf',
  //     description: 'Warm and cozy - exactly what you need for the winter.',
  //     price: 19.99,
  //     imageUrl:
  //         'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  //   ),
  //   Product(
  //     id: 'p4',
  //     title: 'A Pan',
  //     description: 'Prepare any meal you want.',
  //     price: 49.99,
  //     imageUrl:
  //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  //   ),
  // ];

  // var _showFavorite = false;

  final String authToken;

  List<Product> _items = [];

  Products(this.authToken, this._items);

  List<Product> get items {
    // if (_showFavorite == true) {
    //   return _items.where((item) => item.isFavorite).toList();
    // }

    return [
      ..._items
    ]; // use spread operator to create instance instead of the array itself to avoid being mutated
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }

  Future<void> addProduct(Product newProduct) async {
    final url =
        'https://kaings-flutter-proj6.firebaseio.com/products.json?auth=$authToken';
    // const url = 'https://kaings-flutter-proj6.firebaseio.com/products'; // test error handling

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            'isFavorite': newProduct.isFavorite,
          }));

      final addedProduct = new Product(
          id: json.decode(response.body)['name'],
          title: newProduct.title,
          description: newProduct.description,
          price: newProduct.price,
          imageUrl: newProduct.imageUrl);

      _items.add(addedProduct);

      notifyListeners();
    } catch (err) {
      print('addProduct_err..... $err');
      throw err;
    }
  }

  Future<void> fetchProducts() async {
    final url =
        'https://kaings-flutter-proj6.firebaseio.com/products.json?auth=$authToken';

    try {
      final response = await http.get(url);
      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];

      print('fetchProducts_response..... ${json.decode(response.body)}');

      responseData.forEach((productId, productData) {
        loadedProducts.add(Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFavorite: productData['isFavorite']));
      });

      _items = loadedProducts;

      notifyListeners();
    } catch (err) {
      print('fetchProducts_err..... $err');
      throw err;
    }
  }

  Future<void> removeProduct(String id) async {
    // implements `optimistic updating`: UI behaves an immediate update eventhough
    // it has not yet received confirmation from the server
    // In this case, it will immediately remove the item, and then send request to server
    // if error occurs, the removed item will be restored

    // final url = 'https://kaings-flutter-proj6.firebaseio.com/products/$id';  // test error
    final url =
        'https://kaings-flutter-proj6.firebaseio.com/products/$id.json?auth=$authToken';

    final toBeRemovedProductIndex =
        _items.indexWhere((product) => product.id == id);
    var toBeRemovedProduct = _items[toBeRemovedProductIndex];

    // this won't work. Because normally if there is error occured in server,
    // the error will be thrown (in case of POST). But, server does not throw
    // any error in case of DELETE, which is why we need to manually check
    // the error status code

    // ===== [NOT WORKING] =====
    // http.delete(url).then((response) {
    //   toBeRemovedProduct = null;
    // }).catchError((err) {
    //   _items.insert(toBeRemovedProductIndex, toBeRemovedProduct);
    //   notifyListeners();
    // });

    // ===== [WORKING] =====
    _items.removeAt(toBeRemovedProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    print('removeProduct..... ${response.statusCode}');

    // statuscode that is >=400 is error status code
    if (response.statusCode >= 400) {
      // since server does not throw error for DELETE (when something goes wrong),
      // we need to throw our own error. In this case, we need to create
      // our own custom `Exception` class implementing `Exception` absctract class
      // Exception thrown will be then catch by the following `catchError`

      _items.insert(toBeRemovedProductIndex, toBeRemovedProduct);
      notifyListeners();

      throw HttpException('Delete product failed!');
    }
    toBeRemovedProduct = null;
  }

  // void showFavorite() {
  //   _showFavorite = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavorite = false;
  //   notifyListeners();
  // }
}
