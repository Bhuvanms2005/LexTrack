import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
class LoginScreen extends StatefulWidget{
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState()=> _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  void loginUser() async {

  setState(() {
    _isLoading = true;
  });

  await Future.delayed(const Duration(seconds: 2));

  setState(() {
    _isLoading = false;
  });

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const DashboardScreen(),
    ),
  );
}
  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor:const Color(0xFF1E3A5F),
      body:Center(
        child:SingleChildScrollView(
          child:Container(
            width:350,
            padding: const EdgeInsets.all(25),
            decoration:BoxDecoration(
              color:Colors.white,
              borderRadius:BorderRadius.circular(12),
            ),
            child:Column(
              mainAxisSize:MainAxisSize.min,
              children:[
                const Icon(
                  Icons.balance,
                  size:60,
                  color:Color(0xFFC9A227),
                ),
                const SizedBox(height:10),
                const Text(
                  "LexTrack",
                  style:TextStyle(
                    fontSize:26,
                    fontWeight:FontWeight.bold,
                  ),
                ),
                const Text(
                  "Advocate Case Manager",
                  style:TextStyle(
                    color:Colors.grey,
                  ),
                ),
                const SizedBox(height:30),
                TextField(
                  controller:emailController,
                  decoration:InputDecoration(
                    labelText:"Email",
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height:15),
                TextField(
                  controller:passwordController,
                  obscureText:!_isPasswordVisible,
                  decoration:InputDecoration(
                    labelText:"Password",
                    border:OutlineInputBorder(
                      borderRadius:BorderRadius.circular(8),
                    ),
                    suffixIcon:IconButton(
                      icon:Icon(
                        _isPasswordVisible?Icons.visibility:Icons.visibility_off,
                      ),
                      onPressed:()
                      {
                        setState((){
                          _isPasswordVisible=!_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height:25),
                SizedBox(
                  width: double.infinity,
                  height: 45,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A227),
                    ),

                    onPressed: _isLoading ? null : loginUser,

                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 15),

               Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                    const Text("Don't have an account? "),

                    TextButton(
                    onPressed: () {
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
          ),
        );
      },
      child: const Text("Register"),
    ),

  ],
)

              ],
            ),

          ),
        ),
      ),
    );
  }
}