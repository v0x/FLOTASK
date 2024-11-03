import 'package:flutter/material.dart';

/*
The DUM DUMSS (Dummy Tasks)
*/
class Task {
  final String taskName;
  final Color taskColor;
  final int priority;
  Task({required this.taskName, required this.taskColor, required this.priority});
}

List<Task> generateTasks(){
  final List<Task> tasks = [];
  tasks.add(Task(taskName: "Task 1", taskColor: Colors.blue, priority: 0));
  tasks.add(Task(taskName: "Task 2", taskColor: Colors.pink, priority: 1));
  tasks.add(Task(taskName: "Task 3", taskColor: Colors.green, priority: 2));
  tasks.add(Task(taskName: "Task 4", taskColor: Colors.orange, priority: 3));
  tasks.add(Task(taskName: "Task 5", taskColor: Colors.purple, priority: 4));
  return tasks;
}

//Category Page Code & Logic Stuff:
List<Task> tasks = generateTasks(); 
Map<String, List<Task>> folders = {};
String? openFolder; //WDTD?

class Category extends StatefulWidget{
  @override
  _CategoryState createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  //Folder Logic
  void createFolder(String folderName){
    setState(() {
      folders[folderName] = [];
    });
  }
  void deleteFolder(String folderName) {
    setState(() {
      /* Any tasks that are in the folder that's
      going to be deleted will return to the original
      tasks list so no tasks will be accidently deleted */
      tasks.addAll(folders[folderName]!);
      folders.remove(folderName);
    });
  }

  //Organizational Stuff
  void addTaskToFolder(String folderName, Task task) {
    setState(() {
      tasks.remove(task);
      folders[folderName]?.add(task);
    });
  }
  void removeTaskFromFolder(String folderName, Task task) {
    setState(() {
      folders[folderName]?.remove(task);
      tasks.add(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Tasks"),
        leading: openFolder != null
        ? IconButton(
          onPressed: () {
            setState(() {
              //Sends user back to the main view (aka its the back button)
              openFolder = null;
            });
          }, 
          icon: Icon(Icons.arrow_back),
          ) : null,
      ),
      //Logic for, will we see the main view or inside one of the (child) folders?
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: openFolder == null ? _MainView(): _FolderView(openFolder!),),
    );
  }

  Widget _MainView() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              //Tasks Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Tasks",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: ReorderableListView(
                          onReorder: (prevI, newI) {
                            setState(() {
                              if (newI > prevI) newI -= 1;
                              final item = tasks.removeAt(prevI);
                              tasks.insert(newI, item);
                            });
                          },
                          children: tasks
                          .map((task) => ListTile(
                            key: ValueKey(task.taskName),
                            title: Text(task.taskName),
                            tileColor: task.taskColor.withOpacity(0.1),
                            onTap: () {
                              _MoveTaskAction(task);
                            },
                          )).toList(),
                          ),
                          ),
                  ],
                ),
                ),
                SizedBox(width: 10),
                //Folders Section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text("Folders",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Spacer(),
                        IconButton(
                          onPressed: () async {
                            String folderName = await showDialog(
                              context: context, 
                              builder: (context) => FolderNameDialog(),);
                              if (folderName != null && folderName.isNotEmpty) {
                                createFolder(folderName);
                              }
                          },
                           icon: Icon(Icons.create_new_folder),
                           ),
                      ],
                      ),
                      SizedBox(height: 10),
                      //Displaying the folder(s) if any
                      Expanded(
                        child: ListView(
                          children: folders.keys.map((folderName) {
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text(folderName),
                                tileColor: Colors.blueGrey.withOpacity(0.1),
                                subtitle: Text(
                                  "${folders[folderName]?.length ?? 0} items",
                                  style: TextStyle(fontSize: 12),),
                                trailing: IconButton(
                                  onPressed: () {
                                    deleteFolder(folderName);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$folderName folder deleted')),
                                    );
                                  }, 
                                  icon: Icon(Icons.delete, color: Colors.red,),
                                ),
                              onTap: () {
                                setState(() {
                                  //Opens folder
                                  openFolder = folderName;
                                });
                              },
                              ),
                            );
                          }).toList(),
                        )
                        )
                    ],
                  ))
            ],))
      ]
    );
  }

  Widget _FolderView(String folderName){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Folder: $folderName",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10,),
        Expanded(
          child: ReorderableListView(
            onReorder: (prevI, newI) {
              setState(() {
                if (newI > prevI) newI -= 1;
                  final item = folders[folderName]!.removeAt(prevI);
                  folders[folderName]!.insert(newI, item);
                });
            },
            children: folders[folderName]!
            .map((task) => ListTile(
              key: ValueKey(task.taskName),
              title: Text(task.taskName),
              tileColor: task.taskColor,
            onTap: () {
              removeTaskFromFolder(folderName, task);
            },
            )).toList(),
            ),
          ),
      ],
    );
  }

  void _MoveTaskAction(Task task) {
      String temp = task.taskName;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Move $temp to folder", style: TextStyle(color: Colors.purple),),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: folders.keys.map((folderName) {
                return ListTile(
                  title: Text(folderName),
                  onTap: () {
                    addTaskToFolder(folderName, task);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          );
        },
      );
    }

}

class FolderNameDialog extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Enter Folder Name", style: TextStyle(color: Colors.purple),),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: "Folder Name"),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text("Create"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Cancel"),
        ),
      ],
    );
  }
}