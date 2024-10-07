# touch_assistive

A new Flutter project.

## Getting Started

Import the package #

```flutter pub add touch_assistive```

Use the plugin # Add the following import to your Dart code:

```import 'package:touch_assistive/touch_assistive.dart';```

Create a page:

```
class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          TouchAssistive(
            initialOffset: const Offset(100, 100),
            onPressed: () {},
            buttonSize: 60,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.blue,
              ),
              child: const Icon(
                Icons.touch_app_outlined,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

Now you have touch assistive!

