import 'package:flutter/material.dart';
import 'package:intl/date_symbols.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fb;
import 'package:intl/intl.dart';

void main() => runApp(new TodoApp());

class TodoApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return new MaterialApp(
      title: 'Todo List', 
      home : new TodoList()
    );
  }
}

class TodoList extends StatefulWidget{
  @override
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList>{
List<Todo> _todoItems = [];
final todoController = TextEditingController();
DateTime _selectedDate ;

void _addTodoItem() {
    setState(() => _todoItems.add(
      Todo(task : todoController.text ,
       deadline: _selectedDate)
    ));
  fb.Firestore.instance
     .collection("todo")
     .document(DateTime.now().millisecondsSinceEpoch.toString())
     .setData({
       "task" : todoController.text,
       "deadline" : _selectedDate,
     }).then((onValue) {
       print("Added data to the firebase");
     });
}

void _presentDatePicker(){
    showDatePicker(
      context: context,
       initialDate: DateTime.now(),
        firstDate: DateTime(2020),
         lastDate: DateTime(2021),
         ).then((pickedDate) {
           if(pickedDate==null){
             return;
           }
           setState(() {
             _selectedDate = pickedDate;
           });
         });
  }

void _removeTodo(int index){
  setState(() => _todoItems.removeAt(index));
}

void _promptRemoveTodo(int index){
  showDialog(
    context: context,
    builder: (BuildContext context){
      return new AlertDialog(
        title: new Text('Mark "${_todoItems[index]}" done? '),
        actions: <Widget>[
          new FlatButton(
            child: new Text('CANCEL'),
            onPressed: () => Navigator.of(context).pop()
          ),
          new FlatButton(
            child: new Text('MARK AS DONE'),
            onPressed: () {
              _removeTodo(index);
              Navigator.of(context).pop();
            }
          )
        ]
      );
    }
  );
}

Widget _buildTodoList() {
    return new ListView.builder(
      itemBuilder: (context, index) {
        if(index < _todoItems.length) {
          return _buildTodoItem(_todoItems[index].task, _todoItems[index].deadline , index);
        }
      },
    );
  }

Widget _buildTodoItem(String todoText, DateTime finishdate , int index) {
    return new ListTile(
      title: new Text(todoText),
      subtitle: new Text(' ${ DateFormat.yMd().format(finishdate)}'),
      trailing: new IconButton(
        icon: Icon(Icons.delete),
         onPressed: () =>
            _promptRemoveTodo(index),
           ),
       );
  }

Widget build(BuildContext context) {
  return new Scaffold(
    appBar: new AppBar(
      title: new Text('Todo List')
    ),
    body: _buildTodoList(),
    floatingActionButton: new FloatingActionButton(
      onPressed: _pushAddTodoScreen, // pressing this button now opens the new screen
      tooltip: 'Add task',
      child: new Icon(Icons.add)
    ),
  );
}

void _pushAddTodoScreen() {
  Navigator.of(context).push(
    new MaterialPageRoute(
      builder: (context) {
        return new Scaffold(
          appBar: new AppBar(
            title: new Text('Add a new task')
          ),
          body: new Column(
            children: <Widget> [ 
              TextField(
            autofocus: true,
            controller: todoController,
            decoration: new InputDecoration(
              hintText: 'Enter something to do...',
              contentPadding: const EdgeInsets.all(16.0)
            ),
            ),
            Row(children: <Widget>[
              Text( _selectedDate == null
                       ? 'No Date Chosen'
                       : 'Picked Date: ${ DateFormat.yMd().format(_selectedDate)}'),
               FlatButton(
                 textColor: Theme.of(context).primaryColor,
                 child: Text(
                 'Choose Date', 
                  style: TextStyle(
                  fontWeight: FontWeight.bold,
               ),),
                  onPressed: _presentDatePicker,     
            ),
            
            ],) ,
            RaisedButton(
              child: Text('Add Todo'),
              textColor: Colors.red,
              onPressed: () {
                _addTodoItem();
                todoController.clear();
                //_selectedDate.clear();
                Navigator.pop(context);
              }

              ),
              
            ]
        ),
        );
      }
    )
  );
}
}

class Todo{
  String task;
  DateTime deadline;

  Todo({
    this.task,
    this.deadline,
  });
}
