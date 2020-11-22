
import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:flutter_tools/widget/tutorial/tutorial_builder.dart';
import 'package:free_books/common/app/i18n_strings.dart';
import 'package:free_books/widget/tutorial_builder.dart';

class TutorialBuilder extends DefaultTutorialBuilder {
  final double buttonMinWidth = 80.0;

  @override
  List<double> positionedData(BuildContext context, Rect target) {
    var screenSize = MediaQuery.of(context).size;
    double left, top, right, bottom;
    final xRatio = target.width / screenSize.width;
    final isCentered = (target.center.dx - screenSize.width / 2).abs() / screenSize.width < 0.1;
    final bigTarget = xRatio >= 0.33;
    if (bigTarget || isCentered) {
      left = null;
      right = null;
    } else if (target.center.dx < screenSize.width / 2) {
      left = target.right;
    } else {
      right = screenSize.width - target.left;
    }
    if (target.center.dy < screenSize.height / 2) {
      top = target.bottom;
    } else {
      bottom = screenSize.height - target.top;
    }
    return [left, top, right, bottom];
  }

  @override
  Widget buildBottomButtons(BuildContext context, Function onValidate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSkipAllButton(context),
        _buildOKButton(context, onValidate),
      ],
    );
  }

  Widget _buildOKButton(BuildContext context, Function(BuildContext context) onValidate) {
    if(Theme.of(context).platform == TargetPlatform.iOS) {
      return OutlineButton(
        textColor: Theme.of(context).colorScheme.primary,
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
        onPressed: () => onValidate(context),
        child: Text(
          I18n.of(context).value("tutorial.button.ok"),
        ),
      );
    }
    else {
      return FlatButton(
        minWidth: buttonMinWidth,
        height: 36,
        textColor: Colors.white,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        onPressed: () => onValidate(context),
        child: Text(
          I18n.of(context).value("tutorial.button.ok"),
        ),
      );
    }
  }

  Widget _buildSkipAllButton(BuildContext context) {
    final textColor = Color.lerp(Theme.of(context).colorScheme.secondary, Colors.white, 0.3);
    return FlatButton(
      height: 36,
      minWidth: buttonMinWidth,
      textColor: textColor,
      onPressed: () => this.skipAll(context),
      child: Text(
        I18n.of(context).value("tutorial.button.skip"),
      ),
    );
  }

  void skipAll(BuildContext context) {
    TutorialManager.instance.skip(Tutorial.all);
    Navigator.of(context).maybePop();
  }
}