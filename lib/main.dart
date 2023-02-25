import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class Post {
  final String category;
  final String subject;
  final String link;
  const Post({
    required this.category,
    required this.subject,
    required this.link,
  });
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      category: json['category'],
      subject: json['subject'],
      link: json['link'],
    );
  }
}

Future<List<Post>> fetchPosts(http.Client client) async {
  final response = await client.get(Uri.parse('http://localhost:8000/scrap'));
  return compute(parsePosts, response.body); // came from foundation.dart
}

List<Post> parsePosts(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Post>((json) => Post.fromJson(json)).toList();
}

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Post>> futurePost;
  late http.Client httpClient;
  @override
  void initState() {
    super.initState();
    httpClient = http.Client();
    futurePost = fetchPosts(httpClient);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.purple, fontSize: 10),
            titleMedium: TextStyle(fontSize: 10)),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<List<Post>>(
            future: fetchPosts(httpClient),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text('${snapshot.error}');
              } else if (snapshot.hasData) {
                return PostsList(posts: snapshot.data!);
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }
}

class PostsList extends StatelessWidget {
  const PostsList({super.key, required this.posts});
  final List<Post> posts;
  final EdgeInsets defaultEdges = const EdgeInsets.all(8);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: defaultEdges,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return ListTile(
            onTap: () {
              launchUrl(Uri.parse(posts[index].link));
            },
            tileColor: Colors.blueAccent,
            title: Text(posts[index].subject),
            leading: Text(posts[index].category));
      },
    );
  }
}
