import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(
      context,
      // if `listen` set to `false`, the listener won't be active.
      // It ONLY subscribes for first value and stop!
      // in this case, it is NOT what we want

      // since listen is false, it will only listen once (for first time only)
      // Therefore, any other changes after the first time won't be listened
      listen: false,
    );
    final cart = Provider.of<Cart>(
      context,
      listen: false,
    ); // `listen` to false because we just need to access the function call (No Need to listen to the state)

    print('this part of widget is rebuilt only ONCE!');

    // `Consumer<Product>` below is basically similar to
    // the above `Provider.of<Product>(context)`. BUT, NOT ONLY THAT!
    // `Consumer` can also be used to only indicate to ONLY partially Re-Build a part of widget
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          child: Image.network(product.imageUrl, fit: BoxFit.cover),
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            // in this part, `Consumer` only partially rebuild this part of the widget.
            // Since technically, this is the only part we need to rebuild & dynamic,
            // this approach fits this way
            // the following argument `child`, is to prevent this part of widget to be rebuild while
            // others are being rebuilt
            builder: (ctx, product, child) {
              print(
                  'this part of widget is rebuilt everytime the product state changes!');

              return IconButton(
                icon: product.isFavorite
                    ? Icon(Icons.favorite)
                    : Icon(Icons.favorite_border),
                color: Theme.of(context).accentColor,
                onPressed: () {
                  product.toggleFavoriteStatus();
                },
              );
            },
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(
                product.id,
                product.price,
                product.title,
              );

              // `hideCurrentSnackBar` so that when you add items quickly,
              // it will dismiss the previous SnackBar (no need to wait 2sec)
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Added item to car!'),
                // `duration` refers to duration of the Snackbar until it disappears
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.undoAddingItem(product.id);
                  },
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
