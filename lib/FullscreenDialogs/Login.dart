import 'package:flutter/material.dart';

import 'package:thrift/API/Transmit.dart';

import 'package:thrift/Functions/EmailValidator.dart';

import 'package:thrift/Instances/Theme.dart';

import 'package:thrift/Widgets/Reusable UI components/EmptyAppBar.dart';
import 'package:thrift/Widgets/Reusable%20UI%20components/ExceptionStatement.dart';


class Login extends StatefulWidget{
  LoginState createState() => LoginState();
}

class LoginState extends State<Login>{

  static const int stage_CHECKING = 0;
  static const int stage_EMAIL = 1;
  static const int stage_PASSWORD = 2;
  static const int stage_OK = 3;
  static const int stage_CODE = 4;
  static const int stage_SIGNED_IN = 5;
  static const int stage_NO_CONNECTION = 6;
  static const int stage_API_ERROR = 7;
  static const int stage_RECOVER_PASSWORD = 8;

  ValueNotifier<int> stageNotifier;

  ValueNotifier<bool> passwordVisibleNotifier;

  FocusNode focusNode;

  String email; bool accountExists;
  String password;
  String code; int codeStatus;

  static const int codeStatus_OK = 0;
  static const int codeStatus_CONFLICT = 1;
  static const int codeStatus_FORBIDDEN = 2;

  @override
  void initState() {
    passwordVisibleNotifier = ValueNotifier(false);
    stageNotifier = ValueNotifier(stage_EMAIL);
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    passwordVisibleNotifier.dispose();
    stageNotifier.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void futureAsync(Future<int> future, Function function) async {
    function(await future);
  }

  GlobalKey<FormState> formKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const EmptyAppBar(color: white,),
      body: Container(
        color: white,
        child: Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            AppIcon(),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: stageNotifier,
                builder: (context, stage, child){
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Center(
                      child: Builder(
                        builder: (context){
                          switch(stage){
                          //Exceptions
                            case stage_NO_CONNECTION:
                              return const ExceptionStatement(
                                errorMessage: "No connection to Cloud",
                                description: "Please check your internet connection and try again",
                                iconData: Icons.announcement,
                              );
                            case stage_API_ERROR:
                              return const ExceptionStatement(
                                errorMessage: "An error on our side",
                                description: "Please check your credentials and try again in a few minutes",
                                iconData: Icons.announcement,
                              );
                          //API
                            case stage_CHECKING:
                              return const CircularProgressIndicator();
                            case stage_RECOVER_PASSWORD:
                              return const CircularProgressIndicator();


                          //LAYOUT
                            case stage_EMAIL:
                              return Flex(
                                direction: Axis.vertical,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  const Comment("Sign in or sign up"),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Form(
                                      key: formKey,
                                      child: TextFormField(
                                        focusNode: focusNode,
                                        decoration: const InputDecoration(
                                          labelText: "E-mail",
                                          hintText: "examplename@domain.com",
                                        ),
                                        onEditingComplete: (){
                                          if(formKey.currentState.validate()) {
                                            formKey.currentState.save();
                                            focusNode.unfocus();
                                            stageNotifier.value = stage_CHECKING;
                                            passwordVisibleNotifier.value = false;
                                          }
                                        },
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (text){
                                          if(text.isNotEmpty && EmailValidator.validate(text)){
                                            email = text;
                                            return null;
                                          } else {
                                            return "Please enter an e-mail";
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8, top: 16),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.alternate_email, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("Enter your household e-mail;", style: const TextStyle(fontSize: 16, color: secondaryText),),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.supervisor_account, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("It's a good idea to have a separate e-mail for your family;", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.info, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("You will use this e-mail to log in, confirm your account, and to restore password.", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        FlatButton(
                                          onPressed: () => Navigator.pop(context),
                                          shape: const StadiumBorder(),
                                          child: const Text("Do it later"),
                                        ),
                                        MaterialButton(
                                          color: colorPrimary,
                                          onPressed: (){
                                            if(formKey.currentState.validate()) {
                                              focusNode.unfocus();
                                              stageNotifier.value = stage_CHECKING;
                                              passwordVisibleNotifier.value = false;
                                              futureAsync(
                                                transmit(
                                                  headers: {
                                                    emailHeader: email,
                                                  },
                                                ),
                                                    (statusCode){
                                                  if(statusCode!=null){
                                                    print(statusCode);
                                                    switch(statusCode){
                                                      case HttpStatus.found:
                                                        accountExists = true;
                                                        stageNotifier.value = stage_PASSWORD;
                                                        break;
                                                      case HttpStatus.notFound:
                                                        accountExists = false;
                                                        stageNotifier.value = stage_PASSWORD;
                                                        break;
                                                      default:
                                                        stageNotifier.value = stage_API_ERROR;
                                                        break;
                                                    }
                                                  } else {
                                                    stageNotifier.value = stage_NO_CONNECTION;
                                                  }
                                                },
                                              );
                                            }
                                          },
                                          textColor: white,
                                          shape: const StadiumBorder(),
                                          child: const Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 24),
                                            child: const Text("Next"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            case stage_PASSWORD:
                              return Flex(
                                direction: Axis.vertical,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Comment(accountExists?"Welcome back!":"Create a password"),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: ValueListenableBuilder<bool>(
                                      valueListenable: passwordVisibleNotifier,
                                      builder: (context, visible, child){
                                        return Form(
                                          key: formKey,
                                          child: TextFormField(
                                            focusNode: focusNode,
                                            keyboardType: TextInputType.visiblePassword,
                                            obscureText: !visible,
                                            decoration: InputDecoration(
                                              labelText: "Password",
                                              suffixIcon: IconButton(icon: Icon(visible?Icons.visibility_off:Icons.visibility), onPressed: () => passwordVisibleNotifier.value = !visible),
                                            ),
                                            validator: (text){
                                              if(text.isNotEmpty){
                                                if(text.length>=8){
                                                  String pwd = text.toLowerCase();
                                                  const String allowedCharacters = "!\"#\$%&'()*+,-./:;<=>?@[\]^_`{|}~abcdefghijklmnopqrstuvwxyz1234567890";
                                                  bool validate = true;
                                                  for(int i=0; i<text.length; i++){
                                                    if(!allowedCharacters.contains(pwd[i])){
                                                      validate = false;
                                                      break;
                                                    }
                                                  }
                                                  if(validate){
                                                    password = text;
                                                    return null;
                                                  } else {
                                                    return "Please use English alphabet letters";
                                                  }
                                                } else {
                                                  return "Please use atleast 8 characters";
                                                }
                                              } else {
                                                return "Please enter a password";
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  accountExists?FlatButton(
                                    onPressed: (){
                                      focusNode.unfocus();
                                      stageNotifier.value = stage_RECOVER_PASSWORD;
                                      passwordVisibleNotifier.value = false;
                                    },
                                    shape: const StadiumBorder(),
                                    child: const Text("Forgot password?"),
                                  ):Container(),
                                  Expanded(
                                    child: ListView(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8, top: 16),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.info, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("Your password should be atleast 8 characters strong;", style: const TextStyle(fontSize: 16, color: secondaryText),),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.security, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("It's recommended to use uppercase letters, numbers, and special characters (!, @, #, \$, etc);", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.verified_user, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("Keep your password private, do not turn on visibility when entering password in public places.", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        FlatButton(
                                          onPressed: () => stageNotifier.value = stage_EMAIL,
                                          shape: const StadiumBorder(),
                                          child: const Text("Go back"),
                                        ),
                                        MaterialButton(
                                          color: colorPrimary,
                                          onPressed: (){
                                            if(formKey.currentState.validate()) {
                                              formKey.currentState.save();
                                              focusNode.unfocus();
                                              stageNotifier.value = stage_CHECKING;
                                              passwordVisibleNotifier.value = false;
                                              futureAsync(
                                                transmit(
                                                  mayHaveJWT: true,
                                                  headers: {
                                                    emailHeader: email,
                                                    passwordHeader: password,
                                                  },
                                                ),
                                                    (statusCode){
                                                  if(statusCode!=null){
                                                    print(statusCode);
                                                    switch(statusCode){

                                                      case HttpStatus.processing:
                                                        codeStatus = codeStatus_OK;
                                                        stageNotifier.value = stage_CODE;
                                                        break;
                                                      case HttpStatus.ok:
                                                        stageNotifier.value = stage_SIGNED_IN;
                                                        break;
                                                      case HttpStatus.forbidden:
                                                        codeStatus = codeStatus_OK;
                                                        stageNotifier.value = stage_CODE;
                                                        break;
                                                      default:
                                                        stageNotifier.value = stage_API_ERROR;
                                                        break;
                                                    }
                                                  } else {
                                                    stageNotifier.value = stage_NO_CONNECTION;
                                                  }
                                                },
                                              );
                                            }
                                          },
                                          textColor: white,
                                          shape: const StadiumBorder(),
                                          child: const Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 24),
                                            child: const Text("Next"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            case stage_CODE:
                              return Flex(
                                direction: Axis.vertical,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Comment(codeStatus == codeStatus_OK ? "Check your inbox" : codeStatus == codeStatus_FORBIDDEN ? "Outdated; enter new code" : "Codes do not match"),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Form(
                                      key: formKey,
                                      child: TextFormField(
                                        focusNode: focusNode,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "Verification code",
                                          hintText: "123-456",
                                        ),
                                        validator: (text){
                                          if(text.isNotEmpty) {
                                            const String numbers = "1234567890";
                                            String cod = "";
                                            for (int i = 0; i <
                                                text.length; i++) {
                                              if (numbers.contains(text[i])) {
                                                cod += text[i];
                                              }
                                            }
                                            if (cod.length != 6) {
                                              return "Please, check your code length";
                                            } else {
                                              code = cod;
                                              return null;
                                            }
                                          } else {
                                            return "Please, enter the code in your inbox";
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8, top: 16),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.info, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("A verification code should appear in your inbox;", style: const TextStyle(fontSize: 16, color: secondaryText),),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.confirmation_number, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("Enter it to confirm your e-mail before you can use your account;", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 16, top: 8),
                                          child: Flex(
                                            direction: Axis.horizontal,
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: const <Widget>[
                                              const Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: const Icon(Icons.timelapse, color: colorPrimaryDark,),
                                              ),
                                              const Expanded(
                                                child: const Padding(
                                                  padding: const EdgeInsets.only(right: 16),
                                                  child: const Text("The code is only valid for 1 hour - in case it is outdated, we will send a new one.", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Flex(
                                      direction: Axis.horizontal,
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        FlatButton(
                                          onPressed: () => stageNotifier.value = stage_PASSWORD,
                                          shape: const StadiumBorder(),
                                          child: const Text("Go back"),
                                        ),
                                        MaterialButton(
                                          color: colorPrimary,
                                          onPressed: (){
                                            if(formKey.currentState.validate()) {
                                              formKey.currentState.save();
                                              focusNode.unfocus();
                                              stageNotifier.value = stage_CHECKING;
                                              futureAsync(
                                                transmit(
                                                  headers: {
                                                    emailHeader: email,
                                                    passwordHeader: password,
                                                    codeHeader: code,
                                                  },
                                                  mayHaveJWT: true,
                                                ),
                                                    (statusCode){
                                                  if(statusCode!=null){
                                                    switch(statusCode){
                                                      case HttpStatus.forbidden:
                                                        codeStatus = codeStatus_FORBIDDEN;
                                                        stageNotifier.value = stage_CODE;
                                                        break;
                                                      case HttpStatus.ok:
                                                        codeStatus = null;
                                                        stageNotifier.value = stage_SIGNED_IN;
                                                        break;
                                                      case HttpStatus.conflict:
                                                        codeStatus = codeStatus_CONFLICT;
                                                        stageNotifier.value = stage_CODE;
                                                        break;
                                                      default:
                                                        stageNotifier.value = stage_API_ERROR;
                                                        break;
                                                    }
                                                  } else {
                                                    stageNotifier.value = stage_NO_CONNECTION;
                                                  }
                                                },
                                              );
                                            }
                                          },
                                          textColor: white,
                                          shape: const StadiumBorder(),
                                          child: const Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 24),
                                            child: const Text("Next"),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                              //On successful sign in (TODO CHANGE THIS SHIT????)
                            case stage_SIGNED_IN:
                              synchronize();
                              return ExceptionStatement(
                                errorMessage: "Successfully signed",
                                description: "Your data will now be syncronized",
                                iconData: Icons.check_circle,
                                solution: MaterialButton(
                                  color: colorPrimary,
                                  textColor: white,
                                  shape: StadiumBorder(),
                                  onPressed: () => Navigator.pop(context),
                                  child: const Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text("Back to Thrift", style: const TextStyle(fontSize: 16),),
                                  ),
                                ),
                              );




                            default: return Container();
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            )/*
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ValueListenableBuilder<int>(
                  valueListenable: stageNotifier,
                  builder: (context, stage, child){
                      case stage_PASSWORD:
                        return Flex(
                          direction: Axis.vertical,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ValueListenableBuilder<bool>(
                              valueListenable: passwordVisibleNotifier,
                              builder: (context, visible, child){
                                return Form(
                                  key: formKey,
                                  child: TextFormField(
                                    focusNode: focusNode,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: !visible,
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      suffixIcon: IconButton(icon: Icon(visible?Icons.visibility_off:Icons.visibility), onPressed: () => passwordVisibleNotifier.value = !visible),
                                    ),
                                    validator: (text){
                                      if(text.isNotEmpty){
                                        if(text.length>=8){
                                          const String allowedCharacters = "!\"#\$%&'()*+,-./:;<=>?@[\]^_`{|}~abcdefghijklmnopqrstuvwxyz1234567890";
                                          bool validate = true;
                                          for(int i=0; i<text.length; i++){
                                            if(!allowedCharacters.contains(text[i])){
                                              validate = false;
                                              break;
                                            }
                                          }
                                          if(validate){
                                            return null;
                                          } else {
                                            return "Please use English alphabet letters";
                                          }
                                        } else {
                                          return "Please use atleast 8 characters";
                                        }
                                      } else {
                                        return "Please enter a password";
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                            FlatButton(
                              onPressed: (){
                                focusNode.unfocus();
                                stageNotifier.value = stage_RECOVERING_PASSWORD;
                                passwordVisibleNotifier.value = false;
                              },
                              shape: const StadiumBorder(),
                              child: const Text("Forgot password?"),
                            ),
                          ],
                        );
                      case stage_CHECKING_PASSWORD:
                        futureAsync(
                          transmit(
                            headers: {
                              emailHeader: email,
                              passwordHeader: password,
                            },
                          ),
                              (statusCode){
                            if(statusCode!=null){
                              switch(statusCode){
                                case HttpStatus.processing:
                                  stageNotifier.value = stage_CODE;
                                  break;
                                case HttpStatus.ok:
                                  stageNotifier.value = stage_SIGNED_IN;
                                  break;
                                case HttpStatus.forbidden:
                                  stageNotifier.value = stage_CODE;
                                  break;
                                default:
                                  stageNotifier.value = stage_API_ERROR;
                                  break;
                              }
                            } else {
                              stageNotifier.value = stage_NO_CONNECTION;
                            }
                          },
                        );
                        return const Center(child: const CircularProgressIndicator());

                      default:
                        return Container();
                    }
                  },
                ),
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: stageNotifier,
              builder: (context, stage, child){
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Builder(
                    builder: (context){
                      switch(stage){
                        case stage_EMAIL:
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Flex(
                              direction: Axis.horizontal,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  shape: const StadiumBorder(),
                                  child: const Text("Do it later"),
                                ),
                                MaterialButton(
                                  color: colorPrimary,
                                  onPressed: (){
                                    if(formKey.currentState.validate()) {
                                      focusNode.unfocus();
                                      stageNotifier.value = stage_CHECKING_EMAIL;
                                      passwordVisibleNotifier.value = false;
                                    }
                                  },
                                  textColor: white,
                                  shape: const StadiumBorder(),
                                  child: const Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: const Text("Next"),
                                  ),
                                ),
                              ],
                            ),
                          );
                        case stage_PASSWORD:
                          return Padding(
                            padding: const EdgeInsets.all(16),
                            child: Flex(
                              direction: Axis.horizontal,
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  shape: const StadiumBorder(),
                                  child: const Text("Do it later"),
                                ),
                                MaterialButton(
                                  color: colorPrimary,
                                  onPressed: (){
                                    if(formKey.currentState.validate()) {
                                      focusNode.unfocus();
                                      stageNotifier.value = stage_CHECKING_PASSWORD;
                                      passwordVisibleNotifier.value = false;
                                    }
                                  },
                                  textColor: white,
                                  shape: const StadiumBorder(),
                                  child: const Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: const Text("Next"),
                                  ),
                                ),
                              ],
                            ),
                          );

                        default:
                          return Container();
                      }
                    },
                  ),
                );
              },
            ),*/
          ],
        ),
      ),
    );
  }
}

/*class LoginState extends State<Login>{
  ValueNotifier<bool> passwordVisibleNotifier;
  ValueNotifier<int> focusedNodeIndex;

  FocusNode emailNode; static const int focused_EMAIL = 0;
  FocusNode passwordNode; static const int focused_PASSWORD = 1;

  TextEditingController emailController;
  TextEditingController passwordController;

  @override
  void initState() {
    passwordVisibleNotifier = ValueNotifier(false);
    focusedNodeIndex = ValueNotifier(null);

    emailNode = FocusNode();
    emailNode.addListener((){
      if(emailNode.hasFocus){
        focusedNodeIndex.value = focused_EMAIL;
      }
    });
    passwordNode = FocusNode();
    passwordNode.addListener((){
      if(passwordNode.hasFocus){
        focusedNodeIndex.value = focused_PASSWORD;
      }
    });

    emailController = TextEditingController();
    passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    passwordVisibleNotifier.dispose();
    focusedNodeIndex.dispose();

    emailNode.dispose();
    passwordNode.dispose();

    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  GlobalKey<FormState> emailKey = GlobalKey();
  GlobalKey<FormState> passwordKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      bottomBar: ValueListenableBuilder<Map<String,dynamic>>(
        valueListenable: authDataNotifier,
        builder: (context, authData, child){
          return MaterialButton(
            onPressed: (){
              bool pwdValid = passwordKey.currentState.validate();
              bool emaValid = emailKey.currentState.validate();
              if(pwdValid && emaValid){
                //ToDo transmit ema & pwd
              }
            },
            color: colorPrimary,
            textColor: white,
            shape: StadiumBorder(),
            child: Text("Connect"),
          );
        },
      ),
      onKeyboardClosed: (){
        passwordNode.unfocus();
        emailNode.unfocus();
        focusedNodeIndex.value = null;
        if(emailController.text.isNotEmpty){
          emailKey.currentState.validate();
        }
        if(passwordController.text.isNotEmpty){
          passwordKey.currentState.validate();
        }
      },
      appBar: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 16),
            child: IconButton(
              icon: const Icon(Icons.close, color: white,),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Padding(
            padding: const EdgeInsets.only(right: 16),
            child: const Text("Connect to Cloud", style: const TextStyle(color: white, fontWeight: FontWeight.w600, fontSize: 20),),
          ),
        ],
      ),
      child: ValueListenableBuilder<Map<String,dynamic>>(
        valueListenable: authDataNotifier,
        builder: (context, authData, child){
          if(authData==null){
            return ValueListenableBuilder<int>(
              valueListenable: focusedNodeIndex,
              builder: (context, index, child){
                return Flex(
                  direction: Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ScreenLabel(label: "Sign in or sign up",),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: emailKey,
                        child: TextFormField(
                          focusNode: emailNode,
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: "E-mail",
                            hintText: "examplename@domain.com",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onEditingComplete: (){
                            if(emailKey.currentState.validate()){
                              passwordNode.requestFocus();
                            }
                          },
                          validator: (text){
                            if(text.isNotEmpty && EmailValidator.validate(text)){
                              return null;
                            } else {
                              return "Please enter an e-mail";
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Form(
                        key: passwordKey,
                        child: ValueListenableBuilder<bool>(
                          valueListenable: passwordVisibleNotifier,
                          builder: (context, passwordVisible, child){
                            return TextFormField(
                              focusNode: passwordNode,
                              controller: passwordController,
                              onEditingComplete: (){
                                if(passwordKey.currentState.validate()){
                                  passwordNode.unfocus();
                                }
                              },
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !passwordVisible,
                              decoration: InputDecoration(
                                  labelText: "Password",
                                  suffixIcon: IconButton(icon: Icon(passwordVisible?Icons.visibility_off:Icons.visibility), onPressed: () => passwordVisibleNotifier.value = !passwordVisible)
                              ),
                              validator: (text){
                                if(text.isNotEmpty){
                                  if(text.length>=8){
                                    const String allowedCharacters = "!\"#\$%&'()*+,-./:;<=>?@[\]^_`{|}~abcdefghijklmnopqrstuvwxyz";
                                    bool validate = true;
                                    for(int i=0; i<text.length; i++){
                                      if(!allowedCharacters.contains(text[i])){
                                        validate = false;
                                        break;
                                      }
                                    }
                                    if(validate){
                                      return null;
                                    } else {
                                      return "Please use English alphabet letters";
                                    }
                                  } else {
                                    return "Please use atleast 8 characters";
                                  }
                                } else {
                                  return "Please enter a password";
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Flex(
                      direction: Axis.horizontal,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: MaterialButton(
                            shape: const StadiumBorder(),
                            onPressed: (){
                              //ToDo restore password
                            },
                            textColor: secondaryText,
                            child: Text("Forgot password?"),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Container(
                          key: ValueKey(index!=null?0:1),
                          child:
                          index!=null?
                          NotGlowingOverscrollIndicator(
                            child: ListView(
                              children: <Widget>[
                                index==focused_EMAIL?
                                Flex(
                                  direction: Axis.vertical,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8, top: 16),
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: const <Widget>[
                                          const Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: const Icon(Icons.alternate_email, color: colorPrimaryDark,),
                                          ),
                                          const Expanded(
                                            child: const Padding(
                                              padding: const EdgeInsets.only(right: 16),
                                              child: const Text("Enter your household e-mail;", style: const TextStyle(fontSize: 16, color: secondaryText),),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: const <Widget>[
                                          const Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: const Icon(Icons.supervisor_account, color: colorPrimaryDark,),
                                          ),
                                          const Expanded(
                                            child: const Padding(
                                              padding: const EdgeInsets.only(right: 16),
                                              child: const Text("It's a good idea to have a separate e-mail for your family;", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: const <Widget>[
                                          const Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: const Icon(Icons.info, color: colorPrimaryDark,),
                                          ),
                                          const Expanded(
                                            child: const Padding(
                                              padding: const EdgeInsets.only(right: 16),
                                              child: const Text("You will use this e-mail to log in, confirm your account, and to restore password.", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                                    :
                                Flex(
                                  direction: Axis.vertical,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8, top: 16),
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: const <Widget>[
                                          const Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: const Icon(Icons.info, color: colorPrimaryDark,),
                                          ),
                                          const Expanded(
                                            child: const Padding(
                                              padding: const EdgeInsets.only(right: 16),
                                              child: const Text("Your password should be atleast 8 characters strong;", style: const TextStyle(fontSize: 16, color: secondaryText),),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: const <Widget>[
                                          const Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: const Icon(Icons.security, color: colorPrimaryDark,),
                                          ),
                                          const Expanded(
                                            child: const Padding(
                                              padding: const EdgeInsets.only(right: 16),
                                              child: const Text("It's recommended to use uppercase letters, numbers, and special characters (!, @, #, \$, etc);", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 16, top: 8),
                                      child: Flex(
                                        direction: Axis.horizontal,
                                        mainAxisSize: MainAxisSize.max,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: const <Widget>[
                                          const Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: const Icon(Icons.verified_user, color: colorPrimaryDark,),
                                          ),
                                          const Expanded(
                                            child: const Padding(
                                              padding: const EdgeInsets.only(right: 16),
                                              child: const Text("Keep your password private, do not turn on visibility when entering password in public places.", style: const TextStyle(fontSize: 16, color: secondaryText),),                                                    ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                          :
                          Container(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            return ExceptionStatement(
              errorMessage: "Successful login",
              description: "You have successfully connected to Thrift Cloud. Your data will be syncronized from now on.",
              iconData: Icons.sync,
              iconColor: colorPrimary,
              solution: MaterialButton(
                color: colorPrimary,
                textColor: white,
                shape: StadiumBorder(),
                onPressed: () => Navigator.pop(context),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text("Alright, thats great", style: const TextStyle(fontSize: 16),),
                ),
              ),
            );
          }
        },
      ),
    );
  }
} */

class Comment extends StatelessWidget{
  final String text;
  const Comment(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(text, style: const TextStyle(color: primaryText, fontSize: 18),),
    );
  }
}

class AppIcon extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30, bottom: 24),
      child: Flex(
        direction: Axis.horizontal,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const <Widget>[
          const Padding(
            padding: const EdgeInsets.only(right: 8),
            child: const Icon(Icons.donut_large, color: colorPrimary, size: 36,),
          ),
          const Text("Thrift", style: const TextStyle(color: colorPrimaryDark, fontSize: 22, fontWeight: FontWeight.w600),),
        ],
      ),
    );
  }
}