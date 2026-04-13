import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pencarian")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SearchBar(
            hintText: "Cari Kelas",
            leading: const Icon(Icons.search),
            onChanged: (value) {},
          ),
        ),
      ),
    );
  }
}
