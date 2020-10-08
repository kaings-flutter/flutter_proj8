import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../screens/edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products-screen';

  Future<void> onPullRefresh(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);

    // to prove there is no INFINITE REBUILD, the following code only printed once
    // when the page reload & when onPullRefresh is executed
    print('rebuilding UserProductsScreen..... ');

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder(
          future: onPullRefresh(context),
          builder: (ctx, dataSnapshot) =>
              dataSnapshot.connectionState == ConnectionState.waiting
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Consumer<Products>(
                      builder: (ctx, productsData, consumerChild) =>
                          RefreshIndicator(
                        onRefresh: () => onPullRefresh(context),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: (ctx, idx) => UserProductItem(
                              productsData.items[idx].id,
                              productsData.items[idx].title,
                              productsData.items[idx].imageUrl,
                            ),
                          ),
                        ),
                      ),
                    )),
    );
  }
}
