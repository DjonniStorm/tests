import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as Math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'test app',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            primary: const Color.fromARGB(255, 252, 89, 39),
          ),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class WordPairExtension extends WordPair {
  int? _index;
  WordPair? _pair;
  WordPairExtension(super.first, super.second, int index) {
    _index = index;
    _pair = WordPair(first, second);
  }

  WordPairExtension.fromPair(WordPair pair, int index)
    : super(pair.first, pair.second);

  static WordPairExtension random() {
    int randIndex = Math.Random().nextInt(1000);
    final pair = WordPair.random();
    return WordPairExtension(pair.first, pair.second, randIndex);
  }

  int? get index => _index;
  WordPair? get pair => _pair;
}

class MyAppState extends ChangeNotifier {
  var current = WordPairExtension.random();
  void getNext() {
    current = WordPairExtension.random();
    notifyListeners();
  }

  var favorites = <WordPairExtension>[];

  bool checkContains() => favorites.contains(current);

  void toggleFavorite() {
    if (checkContains()) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }

    notifyListeners();
  }

  void removeFavorite(int index) {
    favorites = favorites.where((x) => x.index != index).toList();
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget? page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    print('selected: $value');
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.checkContains()) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(text: pair.pair!),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var fav = appState.favorites;
    if (fav.isEmpty) {
      return Center(child: Text('No favs'));
    }
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'You have '
            '${fav.length} favorites:',
          ),
        ),
        for (var pair in appState.favorites)
          SimpleListItem(
            pair: pair,
            onClick: (index) {
              appState.removeFavorite(index);
            },
          ),
      ],
    );
  }
}

class SimpleListItem extends StatelessWidget {
  final WordPairExtension pair;
  final void Function(int index) onClick;
  const SimpleListItem({super.key, required this.pair, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              print('pressed, $key');
              onClick(pair.index!);
            },
            icon: Icon(Icons.favorite),
          ),
          Text(pair.asLowerCase),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key, required this.text});
  final WordPair text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onPrimary,
      fontFamily: 'Times New Roman',
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text.asLowerCase,
          style: style,
          semanticsLabel: "${text.first} ${text.second}",
        ),
      ),
    );
  }
}
