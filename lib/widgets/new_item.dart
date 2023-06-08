// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
//import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/models/grocery_item.dart';//bundle all the thing imported, into an object 'http'

class NewItem extends StatefulWidget{
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem>{
  bool _isSending = false;
  final _formKey = GlobalKey<FormState>();
  String _enteredName = '';
  int _enteredQuantity = 1;
  Category _selectedCategory = categories[Categories.vegetables]!;
  void _saveItem() async{
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.
      https(
        'shopping-list-app-9701b-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json'
      );
      final response = await http.post(//it takes time to load into server so await async
        url,
        headers: {
          'Content-type':'Application/json',
        },
        body: json.encode({
          'name': _enteredName, 
          'quantity': _enteredQuantity, 
          'category': _selectedCategory.title
        })
      );
      
      print(response.body);//that is returned by backend, typically id is returned
      print(response.statusCode);//200 4xx 5xx to indicate status
      final Map<String,dynamic> resData = json.decode(response.body);
      // ignore: use_build_context_synchronously
      if(!context.mounted){
        return;
      }
      //using context in async may cause problems as we may use an outdated context so to avoid we have the above condition
      Navigator.of(context).pop(GroceryItem(
        id: resData['name'], 
        name: _enteredName, 
        quantity: _enteredQuantity, 
        category: _selectedCategory
      ));
      /*Navigator.of(context).pop(GroceryItem(
        id: DateTime.now().toString(), 
        name: _enteredName, 
        quantity: _enteredQuantity, 
        category: _selectedCategory
      ));*/
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Add a new item'),
      ),
      body: Padding( 
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column( 
            children: [ 
              TextFormField( 
                //instead of textfield 
                maxLength: 50,
                decoration: const InputDecoration( 
                  label: Text('Name'),
                ),
                validator: (value) {//value is that text we entered automatically passed by flutter
                  if(value == null || value.isEmpty || value.trim().length<=1){
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                } ,
                onSaved: (value){
                  _enteredName = value!;
                },
              ),
              Row(  
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [ 
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(  
                        label: Text('Quantity')
                      ),
                      initialValue: '1',
                      validator: (value){
                        if(value == null || value.isEmpty || int.tryParse(value) == null || int.tryParse(value)! <= 0){
                          return 'Must be a valid positive number.';
                        }
                        return null;
                      },
                      onSaved: (value){
                        _enteredQuantity = int.parse(value!);
                      },
                     ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [ 
                        for(final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row( 
                              children: [ 
                                Container( 
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 8),
                                Text(category.value.title)
                              ],
                            )
                          )
                      ], 
                      onChanged: (value){
                        /*setState(() {
                          _selectedCategory = value!;
                        });*/
                        _selectedCategory = value!;
                        //there is no need of using set state, it automatically gets updated 
                      }
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Row( 
                mainAxisAlignment: MainAxisAlignment.end,
                children: [ 
                  TextButton(
                    onPressed: _isSending? null : (){
                      _formKey.currentState!.reset();
                    }, 
                    child: const Text(' Reset ')
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSending? null: _saveItem, 
                    child: _isSending?
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(),
                    )
                    : const Text('Add Item')
                    )
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}