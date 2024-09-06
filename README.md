# flotask

A new Flutter project. Test

## To run:

PREREQS: use ANDROID 14 API 34 and use PIXEL 8 API 34 as android emulator

1. cd project directory
2. flutter pub get
3. make sure to install node.js to use npm command
4. install firebase cli via npm: `npm install -g firebase-tools`
5. firebase login {use google email}
6. then add firebase cli to path
7. install flutterfire: `dart pub global activate flutterfire_cli`
8. in vscode, use android device emulation in command palette or bottom right of vscode
9. flutter run


## Project Management
Each person works on their own branch. Create a new branch with the feature you are working on.

Use the screens directory to update the screen you are working on

Can also add a components directory if the Widget is reusable

## Flutter notes

- use material UI for android UI
- stateless widgets cannot change their state during the runtime of the app
    - type in `stl` to get a shortcut for creating a stateless widget class
- stateful widgets can change their state and can be REDRAWN onto the screen any number of times while the app is in action.
- using the const keyword before MaterialApp means the value of the variable is known at compile time (so stateless widgets)
- in the MaterialApp object, set the value `debugShowCheckedModeBanner: false`
- the build method returns a Widget. You can find widgets at this website: https://docs.flutter.dev/ui/widgets/basics
    - Scaffold Widget is like a container that provides MANY widgets, such as AppBar, FloatingActionButton, Drawer, SnackBar, BottomNavigationBar
        - To add widgets inside a Scaffold object, u pass it with the builtin key like `appBar` and add an object as the value: `AppBar()`


- u can add fonts creating a fonts directory AND update the pubspec.yaml file of the font family. THEN in terminal, run `flutter pub get`. So anytime u have to update the pubspec.yaml file, run this command. TO have a font apply to all text in app, go to main.dart and add `theme: ThemeData(fontFamily: "poppins")

- each widget class has its own properties. For example, Text widget has the style property with the TextStyle class which has the properties of color, font size, font weight. The AppBar widget can have the property of backgroundColor. 


To get rid of shadow, use the shadow property set to 0


To use SVG, use the flutter svg package


U can import libaries in the pubspec.yaml file with the name of the package; THEN run flutter pub get. Also make sure to create an assets/icons/ folder with svg files. Then, include them in the pubspec.yaml file in the assets property. Then, u can add svg images as a property value in a Widget by doing: `child: SvgPicture.asset("assets/icons/<svgfile.svg>")


To have a button on the left side of the AppBar, use the leading property set to the Container widget. The Container widget lets u set the height and width and padding. To fill the background of a Container, use the decoration property set to BoxDecoration widget, which has the properties of color and borderRadius (rounded edges). Another helpful design is to set the margin of the Container by doing: `margin: EdgeInsets.all(10)` 


Also, in Flutter, to specify a color, you must add `0xFF` before the hex color code


Another helpful tip is to use the aliggment property like: `alignment: Alignment.center` so u can then specify the height and widgth of any child Widget inside the parent widget


TO add a button on the RIGHT SIDE of the appBar, you have to add the `actions` property, which takes in an array value. You can copy and paste the code from the leading property



NOTE that the Container widget is not clickable. To make them clickable, you have to use the `GestureDetector` widget, using the `onTap` property, which has the value of a function by doing: `() {}` 


For cleaner code such as cleaning up the appBar widget value in the main build function, in the Scaffold widget property of appBar. Click on the yellow lightbulb in vscode, then click the extract method to create it as a method


If you see widgets are under each other, use the Column widget, using the property: body. You can then pass child widgets inside the Column widget using the `children` property.


For text input, use the TextField widget. To decorate the TextField, use the InputDecoration widget. To decorate the border of the input, use the OutlineInputBorder inside the InputDecoration. View video timestamp for details. 

To add icons on the left side of the input box, use the prefixIcon property. On the right side, use the suffixIcon. To reduce the size of the icon, use the Padding widget with the svg inside the widget as the `child` property


## ROW widget
Widgets are placed horizontally next to each other like a row. There is cross axis aligment refers to the vertical positioning. Main axis aligment refers to the horizontal positioning. To do this in flutter, they are proeprties in the Row widget: `mainAxisAlignment: MainAxisAlignment.end`


ANOTHER tip in vscode is that u can wrap a Widget with what you already habe using the yellow lightbulb icon. 


another tip: to set padding only on one side like the left side: `padding: const EdgeInsets.only(left: 20)


To have a list of items in flutter that have the same design but different text, use the `ListView.builder` widget which takes in a `itemBuilder` property which takes in a list of returned Widgets. To add different "models", create a models folder, where u will create a class that takes in different parameters that will make each model different from each other. View youtube timestamp of `16:07` for details. Another property thets needed is the `itemCount: categories.length` to specify the number of items


To call a method from a class, u can EITHER instantiate the class or make the class method a static method so u dont need to instantiate it. 

You must change a stateless widget to stateful to use the `initState` method. Then call the custom method u defined at the BEGINNING of the build method so that the list is filled first and then the widgets are displayed. 



helpful property for scroll direction: `scrollDirection: Axis.horizontal` 


Instead of ListView.Builder Widget that connects models, you can use `ListView.separated` to separate models. A required property is the `separatorBuilder` which also takes in a function that returns a Widget, which is a SizedBox to make it a blank box that acts as the separator


To add a variable inside a string in dart: do `$variable`