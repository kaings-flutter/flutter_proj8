import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;

    // since ProductDetailScreen also a child of MyApp widget, we can listen to Products state
    final loadedProduct = Provider.of<Products>(context, listen: false).findById(
        productId); // set `listen` to false: this widget won't rebuild even there is changes in Products state. When `listen` is set to `false`, it will ONLY listen for ONCE only!! (NOT ACTIVE LISTENER)

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300, // image height when it is expanded to be image
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                SizedBox(height: 10),
                Text(
                  '\$${loadedProduct.price}',
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    loadedProduct.description,
                    textAlign: TextAlign.center,
                    softWrap: true,
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                      'some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here '),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                      'some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here '),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                      'some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here '),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                      'some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here '),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 60),
                  child: Text(
                      'some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here some random description here '),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
