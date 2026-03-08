import 'package:flutter/material.dart';
import 'package:rwnaqk/widgets/common/app_page_loading.dart';
import 'package:rwnaqk/widgets/common/app_error_state.dart';
import 'package:rwnaqk/widgets/common/app_no_internet_state.dart';

class TestStatesScreen extends StatelessWidget {
  const TestStatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('States Test')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [

          /// Loading
          AppPageLoading(
            title: "Loading products...",
            subtitle: "Please wait a moment",
            expanded: false,
          ),

          SizedBox(height: 40),

          /// Error
          AppErrorState(
            title: "Failed to load products",
            subtitle: "Something went wrong",
            expanded: false,
          ),

          SizedBox(height: 40),

          /// No internet
          AppNoInternetState(
            title: "No internet connection",
            subtitle: "Please check your network",
            expanded: false,
          ),
        ],
      ),
    );
  }
}