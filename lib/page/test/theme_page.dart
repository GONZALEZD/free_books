import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tools/flutter_tools.dart';
import 'package:free_books/application.dart';
import 'package:free_books/common/app/i18n_strings.dart';


class ThemePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  ScrollController scrollController;
  List<ThemeData> displayedThemes;
  int selectedGroup;
  AppTheme theme;

  @override
  void initState() {
    super.initState();
    this.scrollController = TrackingScrollController();
    this.displayedThemes = [Application.get().light, Application.get().dark];
    this.selectedGroup = null;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: this.displayedThemes.first,
      child: Scaffold(
        appBar: AppBar(
          title: Text(I18n.of(context).value("title")),
          actions: [buildMenu(context)],
        ),
        body: SingleChildScrollView(
          controller: scrollController,
          child: Row(
            children: this.displayedThemes.map((theme) {
              return Flexible(
                child: Theme(
                  data: theme,
                  child: Material(
                    child: createDesign(theme: theme),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildMenu(BuildContext context) {
    return PopupMenuButton<List<ThemeData>>(
      icon: Icon(Icons.more_vert),
      initialValue: this.displayedThemes,
      itemBuilder: (context) {
        return [
          PopupMenuItem<List<ThemeData>>(child: Text("Light theme"), value: [this.theme.light]),
          PopupMenuItem<List<ThemeData>>(child: Text("Dark theme"), value: [this.theme.dark]),
          PopupMenuItem<List<ThemeData>>(
              child: Text("Both themes"), value: [this.theme.light, this.theme.dark]),
          PopupMenuItem(
            child: GestureDetector(
              child: Text("Change colors"),
              onTap: () => this.chooseColors(context),
            ),
          ),
        ];
      },
      onSelected: this.selectTheme,
    );
  }

  Future<void> chooseColors(BuildContext context) async {
    var newTheme = await showDialog(
      context: context,
      builder: (context) => ThemeColorPickerDialog(
        primary: this.theme?.primaryColor,
        accent: this.theme?.accentColor,
      ),
    );
    this.theme = newTheme ?? this.theme;
    if (this.displayedThemes.length == 2) {
      this.displayedThemes = [theme.light, theme.dark];
    } else {
      switch (this.displayedThemes.first.brightness) {
        case Brightness.light:
          this.displayedThemes = [theme.light];
          break;
        case Brightness.dark:
          this.displayedThemes = [theme.dark];
          break;
      }
    }
    Navigator.of(context).pop();
    setState(() {});
  }

  void selectTheme(List<ThemeData> themes) {
    setState(() {
      this.displayedThemes = themes;
    });
  }

  Widget createDesign({ThemeData theme}) {
    var wrap = ({Widget child}) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: IntrinsicHeight(child: child),
      );
    };
    return Builder(
      builder: (context) {
        return ListTileTheme(
          iconColor: theme.iconTheme.color,
          child: Container(
            color: theme.backgroundColor,
            padding: EdgeInsets.all(8),
            child: Column(
              children: buildDesignWidgets(context).map((w) => wrap(child: w)).toList(),
            ),
          ),
        );
      },
    );
  }

  List<Widget> buildDesignWidgets(BuildContext context) {
    return <Widget>[
      ...buildColors(context),
      ...buildTexts(context),
      ...buildTextFields(context),
      ...buildCards(context),
      ...buildFAB(context),
      ...buildFlatButtons(context),
      ...buildListTile(context),
      ...buildSegmentedControl(context),
    ];
  }

  Widget _buildColorRow({String text, Color textColor, Gradient gradient, Color boxColor}) {
    double size = 40.0;
    boxColor = gradient == null ? (boxColor ?? textColor) : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(child: Text(text, style: TextStyle(color: textColor))),
        Container(
          height: size,
          width: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: boxColor,
            gradient: gradient,
            border: Border.all(color: Colors.grey, width: 2.0),
          ),
          margin: EdgeInsets.only(left: 12.0),
        ),
      ],
    );
  }

  List<Widget> buildColors(BuildContext context) {
    var theme = Theme.of(context);

    return <Widget>[
      _buildColorRow(
        text: "Primary color",
        textColor: theme.primaryColor,
      ),
      _buildColorRow(text: "Accent color", textColor: theme.accentColor),
      _buildColorRow(
        textColor: Theme.of(context).textTheme.bodyText1.color,
        text: "Gradient H",
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.accentColor],
        ),
      ),
      _buildColorRow(
        textColor: Theme.of(context).textTheme.bodyText1.color,
        text: "Gradient V",
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.accentColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    ];
  }

  List<Widget> buildTexts(BuildContext context) {
    var theme = Theme.of(context).textTheme;
    var toTest = {
      "[Card + List] Body text Body text Body text": theme.bodyText1,
      "[Card + List] Body sub text Body sub text": theme.bodyText2,
      "Subtitle 1 Subtitle 1": theme.subtitle1,
      "Subtitle 2 Subtitle 2": theme.subtitle2,
      "Headline 1": theme.headline1,
      "Headline 2": theme.headline2,
      "Headline 3": theme.headline3,
      "Headline 4": theme.headline4,
      "Headline 5": theme.headline5,
      "Headline 6": theme.headline6,
      "Button text Button text": theme.button,
      "Caption Caption Caption ": theme.caption,
      "Overline Overline Overline": theme.overline
    };
    return toTest.map((key, value) => MapEntry(key, Text(key, style: value))).values.toList();
  }

  List<Widget> buildTextFields(BuildContext context) {
    return [
      TextField(controller: TextEditingController(text: "Text input field")),
      TextField(
        controller: TextEditingController(),
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.person),
            hintText: "HINT of input field",
            labelText: "Field title",
            helperText:
                "This is an helper text that may be used to inform use about what needs to be filled in there."),
      ),
      TextField(
        controller: TextEditingController(text: "Disabled input text"),
        enabled: false,
        decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock), suffixIcon: Icon(Icons.remove_red_eye_sharp)),
      ),
      TextField(
        controller: TextEditingController(text: "Input text with build counter"),
        buildCounter: this._textFieldCounter,
        maxLength: 500,
      ),
      TextField(
        controller: TextEditingController(text: "Input text with error"),
        decoration: InputDecoration(
          labelText: "Label text",
          errorText: "The field must not contain the keyword 'error' in it",
        ),
      ),
    ];
  }

  Widget _textFieldCounter(BuildContext context,
      {int currentLength, int maxLength, bool isFocused}) {
    return Text("$currentLength/$maxLength");
  }

  List<Widget> buildCards(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text("Card title", style: textTheme.bodyText1),
              Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean tristique ac quam eget mollis. Aliquam non vulputate nisi. Praesent molestie eleifend feugiat.",
                style: textTheme.bodyText2,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, bottom: 4),
                child: TextField(
                  controller: TextEditingController(text: "COUCOU"),
                  decoration: InputDecoration(prefixIcon: Icon(Icons.edit)),
                ),
              ),
            ],
          ),
        ),
      ),
      Card(
        color: Theme.of(context).primaryColor,
        shadowColor: Theme.of(context).primaryColor,
        elevation: 6.0,
        shape: BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          side: BorderSide(color: Colors.white, width: 1, style: BorderStyle.solid),
        ),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Text("Card title (body text 1)",
                  style: textTheme.bodyText1.copyWith(color: Colors.white)),
              Text(
                "Body text 2 : Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean tristique ac quam eget mollis. Aliquam non vulputate nisi. Praesent molestie eleifend feugiat.",
                style: textTheme.bodyText2.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> buildFAB(BuildContext context) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          heroTag: Object(),
          child: Icon(Icons.add),
          onPressed: () {},
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton.extended(
          heroTag: Object(),
          label: Text("FAB"),
          icon: Icon(Icons.add),
          onPressed: () {},
        ),
      ),
    ];
  }

  List<Widget> buildFlatButtons(BuildContext context) {
    return [
      FlatButton.icon(onPressed: () {}, icon: Icon(Icons.autorenew), label: Text("FlatButton 2")),
      FlatButton(onPressed: () {}, child: Text("FlatButton"))
    ];
  }

  List<Widget> buildListTile(BuildContext context) {
    return [
      ListTile(
        title: Text("List tile title", overflow: TextOverflow.ellipsis),
        subtitle: Text("List tile subtitle", overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.style),
        leading: Icon(Icons.new_releases),
      )
    ];
  }

  List<Widget> buildSegmentedControl(BuildContext context) {
    var wrapperBuilder = ({Widget child}) {
      return DefaultTextStyle(
        style: Theme.of(context).textTheme.bodyText1,
        child: SizedBox(
          height: 48.0,
          width: double.infinity,
          child: child,
        ),
      );
    };
    return [
      wrapperBuilder(
        child: CupertinoSlidingSegmentedControl<int>(
          children: {
            0: Text("None"),
            1: Text("One"),
            -1: Text("Many"),
          },
          onValueChanged: (value) => setState(() => this.selectedGroup = value),
          groupValue: this.selectedGroup,
        ),
      ),
      wrapperBuilder(
        child: CupertinoSlidingSegmentedControl<int>(
          children: {
            0: Icon(Icons.volume_off),
            1: Icon(Icons.volume_down),
            -1: Icon(Icons.volume_up),
          },
          onValueChanged: (value) => setState(() => this.selectedGroup = value),
          groupValue: this.selectedGroup,
        ),
      ),
      wrapperBuilder(
        child: CupertinoSegmentedControl<int>(
          children: {
            0: Text("None"),
            1: Text("One"),
            -1: Text("Many"),
          },
          onValueChanged: (value) => setState(() => this.selectedGroup = value),
          groupValue: this.selectedGroup,
        ),
      ),
    ];
  }
}

class ThemeColorPickerDialog extends StatefulWidget {
  final Color primary;
  final Color accent;

  ThemeColorPickerDialog({this.primary, this.accent});

  @override
  State<StatefulWidget> createState() => _ThemeColorPickerDialogState();
}

class _ThemeColorPickerDialogState extends State<ThemeColorPickerDialog>
    with SingleTickerProviderStateMixin {
  Color primarySelected;
  Color accentSelected;

  TabController tabController;

  @override
  void initState() {
    super.initState();
    this.primarySelected = this.widget.primary;
    this.accentSelected = this.widget.accent;
    this.tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didUpdateWidget(ThemeColorPickerDialog oldWidget) {
    this.primarySelected = oldWidget.primary;
    this.accentSelected = oldWidget.accent;
    this.tabController.index = 0;
    super.didUpdateWidget(oldWidget);
  }

  _ThemeColorPickerDialogState({this.primarySelected});

  @override
  Widget build(BuildContext context) {
    return IconDialog(
      icon: GradientIcon(
        Icons.palette,
        LinearGradient(
          colors: [Colors.greenAccent, Colors.blue],
          stops: [0.2, 0.7],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        size: 60,
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return DefaultTextStyle(
      style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
      child: Container(
        constraints: BoxConstraints.tightFor(width: 400, height: 400),
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Expanded(child: _buildTabs()),
            _buildControlButtons(context),
          ],
        ),
      ),
    );
  }

  Widget __buildTab(String title, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24,
          height: 24,
          margin: EdgeInsets.only(right: 8),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        Text("$title"),
      ],
    );
  }

  Widget _buildTabs() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: TabBar(
            controller: this.tabController,
            labelColor: Theme.of(context).textTheme.bodyText1.color,
            labelPadding: EdgeInsets.all(4),
            tabs: [
              __buildTab("Primary", this.primarySelected),
              __buildTab("Accent", this.accentSelected),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: this.tabController,
            children: [
              _buildColorsGrid(),
              _buildColorsGrid(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RaisedButton(
            elevation: 0.0,
            textColor: Colors.white,
            color: Colors.grey.shade600,
            child: Center(child: Text("Cancel")),
            onPressed: () => Navigator.of(context).pop(),
          ),
          RaisedButton(
            elevation: 0.0,
            textColor: Colors.white,
            color: Colors.blue,
            child: Center(child: Text("OK")),
            onPressed: this.validateColors,
          ),
        ],
      ),
    );
  }

  void validateColors() {
    Navigator.of(context).pop(
      AppTheme.fromColors(
        primary: this.primarySelected,
        accent: this.accentSelected,
      ),
    );
  }

  Widget _buildColorsGrid() {
    return GridView(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 1,
        crossAxisCount: 10,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      children: __createAllMaterialColors().map((color) {
        return __buildColorButton(color);
      }).toList(),
    );
  }

  Widget __buildColorButton(Color color) {
    var child = color != null ? __buildSelectionMarker(color) : null;
    return GestureDetector(
      onTap: () => this.onColorPicked(color),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(child != null ? 40 : 2),
        ),
        child: child,
      ),
    );
  }

  Widget __buildSelectionMarker(Color color) {
    String marker;
    if (color == this.primarySelected) {
      marker = "P";
    } else if (color == this.accentSelected) {
      marker = "A";
    }
    return marker != null
        ? Text(
            marker,
            style: TextStyle(
              color: __estimateMarkerColor(color),
            ),
          )
        : null;
  }

  Color __estimateMarkerColor(Color background) {
    switch (ThemeData.estimateBrightnessForColor(background)) {
      case Brightness.light:
        return Colors.black;
      case Brightness.dark:
        return Colors.white;
      default:
        return Colors.white;
    }
  }

  void onColorPicked(Color color) {
    setState(() {
      if (tabController.index == 0) {
        this.primarySelected = color;
      } else {
        this.accentSelected = color;
      }
    });
  }

  List<Color> __createAllMaterialColors() {
    var colors = Colors.primaries
        .map((color) => [
              color.shade50,
              color.shade100,
              color.shade200,
              color.shade300,
              color.shade400,
              color.shade500,
              color.shade600,
              color.shade700,
              color.shade800,
              color.shade900,
            ])
        .toList()
          ..addAll(Colors.accents.map((color) => [
                color.shade50,
                color.shade100,
                color.shade200,
                color.shade400,
                color.shade700,
              ]));
    return colors.reduce((list1, list2) => list1 + list2);
  }
}