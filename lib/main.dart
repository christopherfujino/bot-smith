import 'package:flutter/material.dart';

const List<Map<String, dynamic>> recipeRoots = <Map<String, dynamic>>[
  <String, dynamic>{
    'name': 'cavebot',
    'children': <Map<String, dynamic>>[],
  },
  <String, dynamic>{
    'name': 'dollbot',
    'children': <Map<String, dynamic>>[
      <String, dynamic>{
        'name': 'ro-bot',
        'children': <Map<String, dynamic>>[],
      }
    ],
  },
];

// Technically not a tree, as it can have multiple roots
class Tree {
  Tree(this.roots);

  List<Node> roots;

  List<T> visit<T>(Function visit) {
    final List<T> results = <T>[];
    for (Node root in roots) {
      results.add(visit(root));
      root.visitChildren<T>(visit, results);
    }
    return results;
  }
}

class Node {
  Node({this.children, this.contents, this.level, this.available = false});

  bool available;
  List<Node> children;
  dynamic contents;
  int level;

  void visitChildren<T>(Function visit, List<T> results) {
    for (Node child in children) {
      results.add(visit(child));
      child.visitChildren(visit, results);
    }
  }

  @override
  String toString() => contents;
}

Node nodeFromMap(Map<String, dynamic> map, int level) => Node(
      children: map['children']
          .map<Node>((Map<String, dynamic> map) => nodeFromMap(map, level + 1))
          .toList(),
      contents: map['name'],
      level: level,
    );

Tree buildTree(List<Map<String, dynamic>> roots) {
  final List<Node> nodeRoots =
      roots.map((Map<String, dynamic> map) => nodeFromMap(map, 0)).toList();
  return Tree(nodeRoots);
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp() : recipeTree = buildTree(recipeRoots) {
    recipeTree.visit<void>((Node recipe) => print('${'  ' * recipe.level}$recipe'));
  }

  final Tree recipeTree;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page', recipeTree: recipeTree),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key key,
    this.title,
    this.recipeTree,
  }) : super(key: key);

  final String title;
  final Tree recipeTree;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
          children: widget.recipeTree
          .visit((Node recipe) => Card(
                  child: ListTile(
                      title: Text(
                          '${' > ' * recipe.level}$recipe',
                      ),
                  ),
          ))
      ),
      //body: Center(
      //  child: Column(
      //      mainAxisAlignment: MainAxisAlignment.center,
      //      children: widget.recipeTree
      //      .visit((Node recipe) => Text(
      //              '${'  ' * recipe.level}${recipe.toString()}',
      //              textAlign: TextAlign.left,
      //      ))
      //),
      //),
    );
  }
}
