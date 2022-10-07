import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:nc_jwt_auth/main.dart';

AlertDialog getAlertDialog(title, content, context) {
  return AlertDialog(
    title: Text("Register failed"),
    content: Text('${content}'),
    actions: <Widget>[
      TextButton(
        child: Text('Close'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

class RegisterPage extends StatefulWidget {
  static String routeName = "/register";
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterData {
  String username = '';
  String password = '';
  String phone = ''; //+125698475 because of +
  String email = '';
}

class UserData extends _RegisterData {
  String token = '';
  String message = '';
  late int id;

  void addData(Map<String, dynamic> responseMap) {
    this.id = responseMap["id"];
    this.username = responseMap["username"];
    this.token = responseMap["token"];
    this.message = responseMap["message"];
  }
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserData userData = UserData();

  void submit() {
    if (this._formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Register();
    }
  }

  void Register() async {
    final url = 'http://tme.mines.unr.edu:5000/Register';
    await http.post(Uri.parse(url), body: {
      'username': userData.username,
      'password': userData.password,
      'email': userData.email
    }).then((response) {
      Map<String, dynamic> responseMap = json.decode(response.body);
      if (response.statusCode == 200) {
        print("body is:" + response.body);
        userData.addData(responseMap);
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => UserPage(userData),),
        // );
      } else {
        print("error");
        if (responseMap.containsKey("message"))
          showDialog(
              context: context,
              builder: (BuildContext context) => getAlertDialog(
                  "Register failed", '${responseMap["message"]}', context));
      }
    }).catchError((err) {
      showDialog(
          context: context,
          builder: (BuildContext context) =>
              getAlertDialog("Register failed", '${err.toString()}', context));
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.cyan,
      appBar: AppBar(
        title: Text(
          'Register',
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.tealAccent,
      ),
      body: Center(
        child: Container(
            padding: EdgeInsets.all(50.0),
            child: Form(
              key: this._formKey,
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  TextFormField(
                      // keyboardType: TextInputType.emailAddress, // Use email input type for emails.
                      decoration: InputDecoration(
                          hintText: 'Username', labelText: 'Username'),
                      onSaved: (value) {
                        this.userData.username = value!;
                      }),
                  TextFormField(
                      keyboardType: TextInputType
                          .phone, // Use email input type for emails.
                      decoration:
                          InputDecoration(hintText: 'phone', labelText: 'phon'),
                      onSaved: (value) {
                        this.userData.phone = value!;
                      }),
                  TextFormField(
                      keyboardType: TextInputType
                          .emailAddress, // Use email input type for emails.
                      decoration: InputDecoration(
                          hintText: 'email', labelText: 'email'),
                      onSaved: (value) {
                        this.userData.email = value!;
                      }),
                  TextFormField(
                      obscureText: true, // To display typed char with *
                      decoration: InputDecoration(
                          hintText: 'Password',
                          labelText: 'Enter your password'),
                      onSaved: (value) {
                        this.userData.password = value!;
                      }),
                  Container(
                    padding: EdgeInsets.all(30.0),
                    width: screenSize.width,
                    child: ElevatedButton(
                      child: Text(
                        'Register',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: this.submit,
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.amberAccent),
                      ),
                    ),
                    margin: EdgeInsets.only(top: 20.0),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}

class UserPage extends StatefulWidget {
  UserData userData;
  UserPage(@required this.userData);
  @override
  State<StatefulWidget> createState() => _UserPageState(userData);
}

class _UserPageState extends State<UserPage> {
  UserData userData;
  Map<String, String> headers = Map();
  List<Widget> posts = [];

  _UserPageState(this.userData);

  @override
  void initState() {
    headers["Authorization"] = 'Bearer ${userData.token}';
    // headers["x-access-token"] = '${userData.username}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('User page'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<Map>(
              future:
                  getUserData(), //sets getServerData method as the expected Future
              builder: (context, snapshot) {
                List<Widget> widgetList = [];
                if (snapshot.hasData) {
                  //checks if response returned valid data
                  widgetList = getUserInfo(snapshot.data);
                } else if (snapshot.hasError) {
                  //checks if the response threw error
                  widgetList.add(Text("${snapshot.error}"));
                } else {
                  widgetList.add(getRowWithText("Id", "${userData.id}"));
                  widgetList.add(getRowWithText("Username", userData.username));
                  widgetList.add(CircularProgressIndicator());
                }
                return Container(
                  height: (screenSize.height - 60) * 0.26,
                  color: Colors.blue[500],
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: widgetList),
                );
              },
            ),
            FutureBuilder<List>(
              future:
                  getServerData(), //sets getServerData method as the expected Future
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  //checks if response returned valid data
                  return SingleChildScrollView(
                    child: Container(
                      height: (screenSize.height - 60) * 0.65,
                      padding: EdgeInsets.all(20.0),
                      child: getPosts(snapshot.data!),
                    ),
                  );
                } else if (snapshot.hasError) {
                  //checks if the response threw error
                  return Text("${snapshot.error}");
                }
                return CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget getPosts(List<dynamic> _posts) {
    for (int i = 0; i < _posts.length; i++) {
      posts.add(getPostCard(_posts[i]));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: posts.length,
      itemBuilder: (BuildContext context, int index) {
        return posts[index];
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }

  Widget getPostCard(post) {
    return Card(
      color: Colors.teal[300],
      child: ListTile(
        subtitle: Text(post),
      ),
    );
  }

  Widget getTextContainer(text) {
    return Container(
      padding: EdgeInsets.only(left: 5, right: 5),
      child: Text(text),
    );
  }

  Widget getRowWithText(label, value) {
    return Row(
      children: <Widget>[
        getTextContainer(label),
        getTextContainer(value),
      ],
    );
  }

  List<Widget> getUserInfo(map) {
    return <Widget>[
      Row(
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                child:
                    Image.network(map["picture"]["medium"], fit: BoxFit.cover),
              ),
            ],
          ),
          Expanded(
            child: Container(
              height: 100,
              padding: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  getRowWithText("Id", '${map["id"]}'),
                  getRowWithText("Username", map["username"]),
                  getRowWithText("First name", map["name"]["first"]),
                  getRowWithText("Last name", map["name"]["last"]),
                ],
              ),
            ),
          ),
        ],
      ),
      getRowWithText("Phone Number", '${map["phone"]}'),
      getRowWithText("Email", map["email"]),
    ];
  }

  Future<Map> getUserData() async {
    late Map<String, dynamic> responseMap;
    final url = 'http://tme.mines.unr.edu:5000/users/getInfo';
    await http.get(Uri.parse(url), headers: headers).then((response) {
      responseMap = json.decode(response.body);
      if (response.statusCode == 200) {
        responseMap = responseMap["userdata"];
      } else {
        if (responseMap.containsKey("message"))
          throw (Exception(responseMap["message"]));
      }
    }).timeout(Duration(seconds: 40), onTimeout: () {
      throw (TimeoutException("fetch from server timed out"));
    }).catchError((err) {
      throw (err);
    });
    return responseMap;
  }

  Future<List> getServerData() async {
    final url = 'http://tme.mines.unr.edu:5000/users/initialPosts';
    late Map<String, dynamic> responseMap;
    await http.get(Uri.parse(url), headers: headers).then((response) {
      responseMap = json.decode(response.body);
      if (response.statusCode == 200) {
        if (!responseMap.containsKey("posts"))
          throw (Exception('error while server fetch'));
      } else {
        if (responseMap.containsKey("message"))
          throw (Exception('${responseMap["message"]}'));
        else
          throw (Exception('error while server fetch'));
      }
    }).timeout(Duration(seconds: 40), onTimeout: () {
      throw (TimeoutException("fetch from server timed out"));
    }).catchError((err) {
      throw (err);
    });
    return responseMap["posts"];
  }
}
