import 'package:flutter/material.dart';
import 'package:flutter_amplify_sdk/flutter_amplify_sdk.dart';
import 'package:expandable/expandable.dart';
import 'package:progress_dialog/progress_dialog.dart';

class Authentication extends StatefulWidget {
  @override
  _AuthenticationState createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  static const String _mailTest = 'test@gmail.com';
  static const String _phoneTest = '+84XXXXXXXX';
  bool isSignedIn = false;
  String userNameAuth = '';
  String idToken = '';
  String accessToken = '';
  String refreshToken = '';
  String accessKeyId = '';
  String secretKey = '';
  String dataPostR = '';
  String dataGetR = '';
  String dataDeleteR = '';
  String identityId = '';
  String confirmCode = "";
  String confirmRestPassCode = "";
  String passCurrent = "";
  String passNew = "";
  String pass = "";
  String userName = "+84xxxxxxxx";
  String password = "xxxxxxx@1";
  String passwordNew = "xxxxxxx@12";

  ProgressDialog dialog;

  @override
  void initState() {
    FlutterAmplifySdk.initialize().then((String statusAmplify) {
      debugPrint(statusAmplify);
    }).catchError((error) {
      debugPrint(error.toString());
    });
    super.initState();
  }

  Widget getTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '\n$title',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        )
      ],
    );
  }

  static const ExpandableThemeData theme = ExpandableThemeData(
    tapHeaderToExpand: true,
    headerAlignment: ExpandablePanelHeaderAlignment.center,
  );

  @override
  Widget build(BuildContext context) {
    dialog = ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: true);
    dialog.style(
        message: "Loading...",
        borderRadius: 10.0,
        backgroundColor: Colors.white,
        progressWidget: const CircularProgressIndicator(),
        elevation: 10.0,
        insetAnimCurve: Curves.easeInOut);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
      child: ListView(
        children: [
          ExpandablePanel(
              header: getTitle('Sign up'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    decoration: const InputDecoration(
                        fillColor: Colors.yellow,
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'UserName'),
                    onChanged: (userReg) {
                      userName = userReg;
                    },
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      final Map<String, String> data = <String, String>{};
                      data['email'] = _mailTest;
                      data['phone'] = _phoneTest;
                      FlutterAmplifySdk.signUp(userName, password, data)
                          .then((tracked) {
                        debugPrint(tracked.isSignUpComplete.toString());
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Confirm Sign Up'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    decoration: const InputDecoration(
                        fillColor: Colors.yellow,
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'Confirm code'),
                    onChanged: (text) {
                      confirmCode = text;
                    },
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.confirmSignUp(userName, confirmCode)
                          .then((tracked) {
                        debugPrint(tracked.isSignUpComplete.toString());
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Sign In'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    style: const TextStyle(color: Colors.red),
                    decoration: const InputDecoration(
                        fillColor: Colors.yellow,
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'Password'),
                    onChanged: (password) {
                      pass = password;
                    },
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.signIn(userName, pass).then((tracked) {
                        debugPrint("sign in success");
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Resend Sign Up Code'),
              theme: theme,
              expanded: RaisedButton(
                onPressed: () async {
                  await _showLoading();
                  FlutterAmplifySdk.resendSignUpCode(userName)
                      .then((signUpResult) {
                    debugPrint(
                        "Resend signUp code: ${signUpResult.isSignUpComplete}");
                    _hideLoading();
                  }).catchError((error) {
                    _hideLoading();
                    debugPrint(error.toString());
                  });
                },
                child: const Text('Check'),
              )),
          ExpandablePanel(
              header: getTitle('Reset Password'),
              theme: theme,
              expanded: RaisedButton(
                onPressed: () async {
                  await _showLoading();
                  FlutterAmplifySdk.resetPassword(userName)
                      .then((resetPassResult) {
                    debugPrint(
                        'Reset pass: ${resetPassResult.isPasswordReset}');
                    _hideLoading();
                  }).catchError((error) {
                    debugPrint(error.toString());
                    _hideLoading();
                  });
                },
                child: const Text('Check'),
              )),
          ExpandablePanel(
              header: getTitle('Confirm Reset Password'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    style: const TextStyle(color: Colors.red),
                    decoration: const InputDecoration(
                        fillColor: Colors.yellow,
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'Confirm reset password code'),
                    onChanged: (text) {
                      confirmRestPassCode = text;
                    },
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.confirmResetPassword(
                              userName, passwordNew, confirmRestPassCode)
                          .then((confirmResetPassResult) {
                        debugPrint(
                            'Confirm Reset pass: $confirmResetPassResult');
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Change Password'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    style: const TextStyle(color: Colors.red),
                    decoration: const InputDecoration(
                        fillColor: Colors.yellow,
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'Current password'),
                    onChanged: (text) {
                      passCurrent = text;
                    },
                  ),
                  TextField(
                    style: const TextStyle(color: Colors.red),
                    decoration: const InputDecoration(
                        fillColor: Colors.yellow,
                        filled: true,
                        border: InputBorder.none,
                        hintText: 'New password'),
                    onChanged: (text) {
                      passNew = text;
                    },
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.changePassword(passCurrent, passNew)
                          .then((changePassResult) {
                        debugPrint('Change pass: $changePassResult');
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Sign Out'),
              theme: theme,
              expanded: RaisedButton(
                onPressed: () async {
                  await _showLoading();
                  FlutterAmplifySdk.signOut().then((result) {
                    debugPrint('Sign out success');
                    _hideLoading();
                  }).catchError((error) {
                    debugPrint(error.toString());
                    _hideLoading();
                  });
                },
                child: const Text('Check'),
              )),
          ExpandablePanel(
              header: getTitle('Get idToken'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    idToken,
                    style: const TextStyle(fontSize: 15),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.getTokens().then((tokens) {
                        setState(() {
                          idToken = tokens.idToken;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        setState(() {
                          idToken = '';
                        });
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Get accessToken'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    accessToken,
                    style: const TextStyle(fontSize: 15),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.getTokens().then((tokens) {
                        setState(() {
                          accessToken = tokens.accessToken;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        setState(() {
                          accessToken = '';
                        });
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Get refreshToken'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    refreshToken,
                    style: const TextStyle(fontSize: 15),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.getTokens().then((tokens) {
                        setState(() {
                          refreshToken = tokens.refreshToken;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        setState(() {
                          refreshToken = '';
                        });
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Get credentials'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'AccessKeyId: $accessKeyId',
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    'SecretKey: $secretKey',
                    style: const TextStyle(fontSize: 15),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.getCredentials().then((credential) {
                        setState(() {
                          accessKeyId = credential.accessKeyId;
                          secretKey = credential.secretKey;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Get Identity Id'),
              theme: const ExpandableThemeData(
                tapHeaderToExpand: true,
                headerAlignment: ExpandablePanelHeaderAlignment.center,
              ),
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    identityId,
                    style: const TextStyle(fontSize: 15),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.getIdentityId().then((identityIdR) {
                        setState(() {
                          identityId = identityIdR;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Get User Status'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    isSignedIn ? "Signed" : "Not Signed",
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    'Username: $userNameAuth',
                    style: const TextStyle(fontSize: 15),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.isSignedIn().then((isSigned) {
                        setState(() {
                          isSignedIn = isSigned;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                      FlutterAmplifySdk.getUsername().then((userNameAuthR) {
                        setState(() {
                          userNameAuth = userNameAuthR;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Call Post API'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    dataPostR,
                    style: const TextStyle(fontSize: 15),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      final bodyPost = <String, dynamic>{};
                      bodyPost["userId"] = "userId";
                      bodyPost["name"] = "userName";
                      bodyPost["age"] = 30;
                      FlutterAmplifySdk.postDataApi(idToken, "/users", bodyPost)
                          .then((dataRes) {
                        setState(() {
                          dataPostR = dataRes;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle("Call Get API"),
              theme: const ExpandableThemeData(
                tapHeaderToExpand: true,
                headerAlignment: ExpandablePanelHeaderAlignment.center,
              ),
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    dataGetR,
                    style: const TextStyle(fontSize: 15),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      final bodyGet = <String, dynamic>{};
                      FlutterAmplifySdk.getDataApi(
                              idToken, "/users/userId", bodyGet)
                          .then((dataRes) {
                        setState(() {
                          dataGetR = dataRes;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Call Delete API'),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    dataDeleteR,
                    style: const TextStyle(fontSize: 15),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      final bodyDelete = <String, dynamic>{};
                      FlutterAmplifySdk.deleteDataApi(
                              idToken, "/users/userId", bodyDelete)
                          .then((dataRes) {
                        setState(() {
                          dataDeleteR = dataRes;
                        });
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Authen With Google '),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.authenWithSocialNetwork(
                              SocialNetwork.google)
                          .then((dataRes) {
                        debugPrint("authen Google Res =========> $dataRes");
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
          ExpandablePanel(
              header: getTitle('Authen With Apple '),
              theme: theme,
              expanded: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RaisedButton(
                    onPressed: () async {
                      await _showLoading();
                      FlutterAmplifySdk.authenWithSocialNetwork(
                              SocialNetwork.apple)
                          .then((dataRes) {
                        debugPrint("authen Apple Res =========> $dataRes");
                        _hideLoading();
                      }).catchError((error) {
                        debugPrint(error.toString());
                        _hideLoading();
                      });
                    },
                    child: const Text('Check'),
                  )
                ],
              )),
        ],
      ),
    );
  }

  Future<void> _showLoading() async {
    if (dialog.isShowing()) {
      await dialog.hide();
    }
    await dialog.show();
  }

  Future<void> _hideLoading() async {
    await dialog.hide();
  }
}
