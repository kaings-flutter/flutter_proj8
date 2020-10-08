import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/products.dart';
import './providers/cart.dart';
import './providers/order.dart';
import './providers/auth.dart';
import './screens/products_overview_screen.dart';
import './screens/auth_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './screens/order_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/splash_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),

        // fetching products from server needs token (from Auth class)
        // `ChangeNotifierProxyProvider` enables passing value easily
        // `ChangeNotifierProxyProvider<X, Y>` refers to:
        // X ..... the provider which becomes the dependency of fetching product
        //         (in this case is Auth, to get token). Dependency Provider always
        //         MUST be before the provider that depends on it (NotifierProvider of Auth MUST be before Products)
        // Y ..... the provider which is the result (Products)
        // If you need more than 1 dependency, use `ChangeNotifierProxyProvider2..3..4.. upto 6`

        // `ChangeNotifierProxyProvider`: `create` set to null to avoid error (in this case)

        ChangeNotifierProxyProvider<Auth, Products>(
          create: null,
          // authData is dynamic value that Products provider gets from Auth provider
          // ONLY Products provider will REBUILD when Auth provider has changes (Others DO NOT REBUILD)
          update: (ctx, authData, previousProductsData) => Products(
              authData.getToken,
              previousProductsData == null ? [] : previousProductsData.items),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Cart(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => Order(),
        )
      ],
      child: Consumer<Auth>(
        builder: (ctx, authData, child) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: authData.isAuth
              ? ProductOverviewScreen()
              : FutureBuilder(
                  // use `FutureBuilder` to subscribe to tryAutoSignIn
                  // when `isAuth` is false, it will trigger `tryAutoSignIn`
                  // if successful, it will result in `isAuth` to be true (_token is available)
                  // if fail, it will go to `AuthScreen`
                  future: authData.tryAutoSignIn(),
                  builder: (ctx, authDataSnapshot) {
                    print('authDataSnapshot..... ${authDataSnapshot.data}');
                    // when the `Future` is pending, show `SplashScreen`
                    return authDataSnapshot.connectionState ==
                            ConnectionState.waiting
                        ? SplashScreen()
                        : AuthScreen();
                  },
                ),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrderScreen.routeName: (ctx) => OrderScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
