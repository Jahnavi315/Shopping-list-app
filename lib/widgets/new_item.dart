import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;//bundle all the thing imported, into an object 'http'

class NewItem extends StatefulWidget{
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItem();
  }
}

class _NewItem extends State<NewItem>{
  final _formKey = GlobalKey<FormState>();
  String _enteredName = '';
  int _enteredQuantity = 1;
  Category _selectedCategory = categories[Categories.vegetables]!;
  void _saveItem(){
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      final url = Uri.
      https(
        'shopping-list-app-9701b-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json'
      );
      http.post(
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
      Navigator.of(context).pop(GroceryItem(
        id: DateTime.now().toString(), 
        name: _enteredName, 
        quantity: _enteredQuantity, 
        category: _selectedCategory
      ));
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
                    onPressed: (){
                      _formKey.currentState!.reset();
                    }, 
                    child: const Text(' Reset ')
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveItem, 
                    child: const Text('Add Item')
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