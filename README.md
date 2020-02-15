# MaterialDesignTextField-iOS
This class is an iOS native code written in swift to achieve the same result and design for material design text fields.

# How to use it?

1- Add FloatingTextField.swift class to your project. 

2- Create a view in your storyboard or .xib file.

3- Assigne the class of the view to FloatingTextField.

4- Connect an outlet of your view to the view controller class.

5- Run the code and checkout the view !

# Features? 

1- Set the placeholder: 
 textFieldController.placeholderText = "Placeholder";

2- Want to have an access to the textField? 
 textFieldController.textField

3- Want to add an error? 
 textFieldController.setErrorText("Your Error", errorAccessibilityValue: nil)
  
4- Want to remove the error? 
 textFieldController.setErrorText(nil, errorAccessibilityValue: nil)

5- How to change the placeholder animation duration?
 textFieldController.animationDuration = 0.2

6- Change the color of active and inActive state?
 textFieldController.activeColor = UIColor(red: 64/255.0, green: 110/255.0, blue: 191/255.0, alpha: 1.0)
 textFieldController.inActiveColor = UIColor(red: 84/255.0, green: 110/255.0, blue: 122/255.0, alpha: 0.8)

7- Use the textField for password? 
 textFieldController.isTextEntrySecured = true
