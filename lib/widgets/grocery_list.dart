// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
//import 'package:shopping_list_app/data/dummy_items.dart';
import 'package:shopping_list_app/widgets/new_item.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceryList extends StatefulWidget{
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  String? _error;
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;

  @override
  void initState() {//initState cant be marked as async instead we can mark other function as await and call that here
  //like _loadItems()
    super.initState();
    print('inside initState');
    _loadItems();
    print('ending initState');
  }

  void _loadItems() async{
    final url = Uri.
      https(
        'shopping-list-app-9701b-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json'
      );
    try{
      final response = await http.get(url);
      print('respone body goes here');
      print(response.body);//nested map,as string
      if(response.statusCode>=400){
        print('status code >= 400');
        setState(() {
          //await Future.delayed(const Duration(seconds: 5));//JUST TO OBSERVE THE ERROR MSG ON SCREEN 
          print('inside setState');
          _error = 'Some error has occured...Unable to fetch data !'.toUpperCase();
        });
        return;
      }
      if(response.body == 'null'){//if error is there, body is also a map that says error
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String,dynamic> listData = json.decode(response.body);//dynamic 
      //Map<String,Map<String,dynamic>> =>Unhandled Exception: type '_Map<String, dynamic>' is not a subtype of type 'Map<String, Map<String, dynamic>>'
      final List<GroceryItem> loadedItems = [];
      print('checkpoint-1');
      for(final item in listData.entries){
        final category  = categories.entries.firstWhere((element) => element.value.title==item.value['category']).value;
        loadedItems.add(GroceryItem(
          id: item.key, 
          name: item.value['name'],
          quantity: item.value['quantity'], 
          category: category
        )
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
      print('loaded items');
    }catch(exception){
      print('caught the exception');
      print(exception);
      //print(response.statusCode);//cant access here
      setState(() {
        _error = 'Something went wrong..Unable to fetch data !';
      });
    } 
  }
  void _addItem() async{
    final newItem = await Navigator.push(context, MaterialPageRoute(builder: (cxt){
    //if await is not there, then before coming back only below statements gets exected thats ofc useless
      return const NewItem();
    }
    )
    );
    print('trying to add an item');//useful to see what await does!!
    //_loadItems();//redundant as we already have new Item data in form screen,so we passed that to this screen
    
    if(newItem == null){
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
    
  }

  void _removeItem(GroceryItem item) async{
    final int removedItemIndex  = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.
      https(
        'shopping-list-app-9701b-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list/${item.id}.json'
      );
    final response = await http.delete(url);//no need to add async beacuse we need not wait for backend to complete process just update UI as we are sure
    if(response.statusCode>=400){
      // ignore: use_build_context_synchronously
      if(!context.mounted){
        return;
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Text('${item.name.toUpperCase()} deletion failed!'),
        ),
      );
      setState(() {
        _groceryItems.insert(removedItemIndex, item);
      });
    }
/*
    // ignore: use_build_context_synchronously
    if(!context.mounted){
        return;
      }
    //send get req and add again--work on it!
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Text('${item.name.toUpperCase()} deleted.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            final response = http.post();
            setState(() {
              _groceryItems.insert(removedItemIndex, item);
            });
          },
        ),
        ),
    );*/
  }
  
  @override
  Widget build(BuildContext context) {
    Widget content = const Center( 
      child: Text('No items added yet!'),
    );
    if(_isLoading){
      print('buffering');
      content = const Center(child: CircularProgressIndicator());//for buffering
    }
    if(_groceryItems.isNotEmpty){
      print('showing content');
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (context, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction){
            _removeItem(_groceryItems[index]);
          } ,
          child: ListTile( 
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            title: Text(_groceryItems[index].name),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        )
      );
    }
    if(_error != null){
      print('error encountered');
      content = Center( 
      child: Text(_error!),
    );
    }
    return Scaffold(
      appBar: AppBar( 
        title: const Text('Your Groceries'),
        actions: [ 
          IconButton(
            onPressed: _addItem, 
            icon: const Icon(Icons.add)
          )
        ],
       ),
      body: content
    );
  }
}