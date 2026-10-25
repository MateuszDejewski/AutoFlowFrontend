import 'package:flutter/material.dart';

import 'navigation/client_navigation.dart';
import 'screens/service_orders_screen.dart';

void openClientApp(BuildContext context) {
  navigateToClientScreen(context, screen: const ClientAppModule());
}

class ClientAppModule extends StatelessWidget {
  const ClientAppModule({super.key});

  @override
  Widget build(BuildContext context) => const ServiceOrdersScreen();
}
