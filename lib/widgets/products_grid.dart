import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavorite;

  ProductsGrid(this.showOnlyFavorite);

  @override
  Widget build(BuildContext context) {
    // since we set `ChangeNotifierProvider` in this widget parents, we can subscribe/listen to the event state in this case `Products` state
    final productsData = Provider.of<Products>(context);
    final products =
        showOnlyFavorite ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        // set provider to each individual Product (since each product has their own favorite state)

        // In this case, it is BEST Practice to use `ChangeNotifierProvider.value` to avoid bug when
        // amount of data is increasing. As explained in main.dart, it is because `products[i]` is
        // existing data. We do not newly instantiate a class to provide to the provider!

        // ChangeNotifierProvider will always clean the old data
        value: products[i],
        child: ProductItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
    );
  }
}
