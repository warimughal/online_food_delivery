// ignore_for_file: prefer_const_constructors, avoid_print, no_leading_underscores_for_local_identifiers, file_names, unused_local_variable, use_build_context_synchronously, avoid_unnecessary_containers, sort_child_properties_last, non_constant_identifier_names, unused_label, unused_element, prefer_interpolation_to_compose_strings

// import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ValueNotifier<String?> selectedOption = ValueNotifier<String?>(null);
  TextEditingController productNameController = TextEditingController();
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productDescriptionController = TextEditingController();

//For Form Validations
  GlobalKey<FormState> formkey = GlobalKey<FormState>();
  void validate() {
    if (formkey.currentState!.validate()) {
      print("Ok");
    } else {
      print("Error");
    }
  }

  Map<String, String> categoryToCollection = {
    'Zinger Burger': 'zinger_burger',
    'Pizza': 'pizza',
    'Shawarma': 'shawarma',
    'Fries': 'fries',
    'Hot Wings': 'hot_wings',
  };

  bool isLoadingImage = false;
  bool isImageUploaded = false;
  //For image Picker

  String? imageUrl;

  Future<void> uploadImageToFirebase(File imageFile) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference storageReference =
        FirebaseStorage.instance.ref().child('product_images/$fileName');

    UploadTask uploadTask = storageReference.putFile(imageFile);
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

    if (snapshot.state == TaskState.success) {
      final downloadUrl = await storageReference.getDownloadURL();
      setState(() {
        imageUrl = downloadUrl; // Set imageUrl to the download URL
        isImageUploaded = true;
      });
    } else {
      // Handle the case where image upload failed
      print('Image upload failed');
      setState(() {
        isImageUploaded = false;
      });
    }
  }

  File? image;
  Future<void> pickImage(source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage == null) {
      return;
    }
    setState(() {
      isLoadingImage = true;
      image = File(pickedImage.path);
    });

    await uploadImageToFirebase(image!);

    setState(() {
      isLoadingImage = false;
    });
  }

  bool isBottomSheetVisible = false;

// Modify the showBottomSheet function to always show the bottom sheet
  void showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.yellow.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Choose Product Photo",
                  style: TextStyle(
                    color: Colors.yellow,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        pickImage(ImageSource.camera);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.camera),
                      label: Text("Camera"),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        pickImage(ImageSource.gallery);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.image),
                      label: Text("Gallery"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  //Check All the SignUp Validations
  bool validateImage() {
    return image != null;
  }

  void _checkDataAndShowMessage(BuildContext context) async {
    var productName = productNameController.text.trim();
    var productPrice = productPriceController.text.trim();
    var productDescription = productDescriptionController.text.trim();
    bool validImage = image != null && validateImage();

    bool isValid = true;
    String message = '';
    Color backgroundColor = Colors.yellow;
    Color textColor = Colors.black;

    if (productName.isEmpty) {
      isValid = false;
      message = 'Product Name is required';
    } else if (productPrice.isEmpty) {
      isValid = false;
      message = 'Product Price is required';
    } else if (selectedOption.value == null || selectedOption.value!.isEmpty) {
      isValid = false;
      message = 'Please select a Category Name';
    } else if (productDescription.isEmpty) {
      isValid = false;
      message = 'Product Description is required';
    } else if (!validImage) {
      isValid = false;
      message = 'Please select a Product photo';
    } else {
      message = 'Saved Successfully';
      backgroundColor = Colors.yellow;
      textColor = Colors.black;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Center(
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(20), // Adjust the radius as needed
          side: BorderSide(
            color: Colors.black, // Set your desired border color here
            width: 2, // Set your desired border width here
          ),
        ),
      ),
    );
  }

  //For Snackbar
  Color backgroundColor = Colors.yellow;
  Color textColor = Colors.black;

  TextStyle validationErrorStyle = TextStyle(
    color: Colors.yellow,
    fontWeight: FontWeight.bold,
    fontSize: 15,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Create Account",
            style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
          ),
          automaticallyImplyLeading: false,
        ),
        backgroundColor: Colors.yellow,
        body: FocusScope(
            child: SingleChildScrollView(
                child: Stack(children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(top: 60.0, left: 70),
              child: Text(
                "Online Food Delivery",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black),
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: Colors.black,
                  ),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 11),
                      child: Form(
                          autovalidateMode: AutovalidateMode.always,
                          key: formkey,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: isLoadingImage
                                      ? CircularProgressIndicator()
                                      : CircleAvatar(
                                          backgroundColor: Colors.yellow,
                                          radius: 40,
                                          backgroundImage: imageUrl != null
                                              ? NetworkImage(imageUrl!)
                                              : null,
                                          child: InkWell(
                                            onTap: () {
                                              showBottomSheet(context);
                                            },
                                            child: Icon(
                                              Icons.camera_alt,
                                              color: Colors.black,
                                              size: 28.0,
                                            ),
                                          ),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Center(
                                      child: DropdownButtonFormField(
                                    value: selectedOption.value,
                                    items: categoryToCollection.keys.map((e) {
                                      backgroundColor:
                                      Colors.yellow;
                                      return DropdownMenuItem(
                                        child: Center(
                                          child: Container(
                                            color: Colors
                                                .yellow, // Set the background color here
                                            child: Center(
                                              child: Text(
                                                e,
                                                style: TextStyle(
                                                  color: Colors
                                                      .black, // Set text color here
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        value: e,
                                      );
                                    }).toList(),
                                    onChanged: (newValue) {
                                      selectedOption.value = newValue;
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors
                                          .yellow, // Set background color here
                                      hintText: "Select Category",
                                      hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide:
                                            BorderSide(color: Colors.black),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      errorStyle: validationErrorStyle,
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please select an option';
                                      } else {
                                        return null;
                                      }
                                    },
                                  )),
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: productNameController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.yellow,
                                    suffixIcon: Icon(
                                      Icons.person,
                                      color: Colors.yellow,
                                    ),
                                    hintText: "Product Name",
                                    hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: Colors.yellow),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: Colors.yellow),
                                    ),
                                    // label: Text(
                                    //   "Product Name",
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.w900,
                                    //       color: Colors.yellow),
                                    // ),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    errorStyle: validationErrorStyle,
                                  ),
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: productPriceController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.yellow,
                                    prefixText:
                                        '\$', // Add a dollar sign as a prefix
                                    suffixIcon: Icon(
                                      Icons.email,
                                      color: Colors.yellow,
                                    ),
                                    hintText: "Product Price in Dollars",
                                    hintStyle: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w900,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: Colors.yellow),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: Colors.yellow),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    errorStyle: validationErrorStyle,
                                  ),
                                  keyboardType: TextInputType
                                      .number, // Set keyboard type to number
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        5), // Limit the length to 5 characters
                                  ],
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                SizedBox(height: 10),
                                TextFormField(
                                  controller: productDescriptionController,
                                  minLines: 3,
                                  maxLines: 5,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.yellow,
                                    // label: Text(
                                    //   "Description",
                                    //   style: TextStyle(
                                    //       fontWeight: FontWeight.w900,
                                    //       color: Colors.yellow),
                                    // ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: Colors.yellow),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      borderSide:
                                          BorderSide(color: Colors.yellow),
                                    ),
                                    hintText: "Enter A Description Here",
                                    hintStyle: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    errorStyle: validationErrorStyle,
                                  ),
                                  validator: (val) {
                                    if (val!.isEmpty) {
                                      return "Max 100 Characters Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                                SizedBox(height: 15),
                                ElevatedButton(
                                    onPressed: () async {
                                      _checkDataAndShowMessage(context);

                                      if (formkey.currentState!.validate() &&
                                          isImageUploaded) {
                                        var productName =
                                            productNameController.text.trim();
                                        var productPrice = '\$' +
                                            productPriceController.text.trim();
                                        var productDescription =
                                            productDescriptionController.text
                                                .trim();
                                        String? selectedCategory =
                                            selectedOption.value;

                                        try {
                                          if (selectedCategory != null) {
                                            String collectionName =
                                                categoryToCollection[
                                                        selectedCategory] ??
                                                    '';

                                            await FirebaseFirestore.instance
                                                .collection(collectionName)
                                                .add({
                                              'productName': productName,
                                              'productPrice': productPrice,
                                              'createdAt':
                                                  FieldValue.serverTimestamp(),
                                              'selectedOption':
                                                  selectedOption.value,
                                              'productDescription':
                                                  productDescription,
                                              'imageUrl': imageUrl,
                                            });

                                            // Clear input fields and update state
                                            productNameController.clear();
                                            productPriceController.clear();
                                            productDescriptionController
                                                .clear();
                                            selectedOption.value = null;
                                            setState(() {
                                              imageUrl = null;
                                              isImageUploaded = false;
                                            });
                                          }
                                        } on FirebaseException catch (e) {
                                          print("Firebase Error: $e");
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              backgroundColor: Colors.red,
                                              content: Center(
                                                child: Text(
                                                  'Error: $e',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                              duration: Duration(seconds: 3),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                side: BorderSide(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.yellow),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          side: BorderSide(
                                              color: Colors.black, width: 2),
                                        ),
                                      ),
                                      elevation: MaterialStateProperty.all(
                                          4), // Add elevation for shadow
                                      shadowColor: MaterialStateProperty.all(
                                          Colors.black), // Set shadow color
                                    ),
                                    child: Text(
                                      "Save",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                      ),
                                    ))
                              ])))))
        ]))));
  }
}
