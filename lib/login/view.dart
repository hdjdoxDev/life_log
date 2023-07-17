import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/frontend.dart';

import '../log/widgets.dart';
import 'viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomView<LoginModel>(
      initModel: (model) => model.init(),
      title: "LifeLog - Login",
      body: (context, model, _) => Column(
        children: [
          Expanded(
            flex: 6,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  controller: model.controllerScroll,
                  child: Column(
                    children: [
                      for (var i = 0; i < model.logs.length; i++)
                        Column(
                          children: [
                            LoginTile(
                              entry: model.logs[i],
                              copyEntry: model.copyLog,
                              deleteEntry: model.deleteLog,
                            ),
                            if (i < model.logs.length - 1)
                              Divider(
                                color: Theme.of(context).colorScheme.secondary,
                                indent: 16,
                                endIndent: 20,
                                thickness: 1,
                                height: 1,
                              ),
                          ],
                        ),
                    ],
                  ),
                )),
          ),
          InkWell(
            onDoubleTap: () => model.goToBottom(),
            child: Column(
              children: [
                Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  thickness: 7,
                ),
                Divider(
                  color: Theme.of(context).colorScheme.secondary,
                  thickness: 7,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  maxLines: 5,
                  minLines: 1,
                  controller: model.controller,
                  style: const TextStyle(color: Colors.white),
                ),
              )),
              LifeIconButton(
                onTap: () => model.getInput(),
                iconData: CupertinoIcons.check_mark,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
