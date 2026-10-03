// ignore_for_file: unused_local_variable, non_constant_identifier_names, prefer_interpolation_to_compose_strings, library_private_types_in_public_api, use_key_in_widget_constructors

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(MaterialApp(
    home: RemoteCTRL(),
    debugShowCheckedModeBanner: false,
  ));
}

class RemoteCTRL extends StatefulWidget {
  @override
  _RemoteCTRLState createState() => _RemoteCTRLState();
}


/// configure your server ip so it can be controller from remote
class Config {
  static const int serverPort = 5288;
    static const String serverIp = "IP ADRESS:${serverPORT}";
  static String get baseUrl => "http://$serverIp:$serverPort";
}



class _RemoteCTRLState extends State<RemoteCTRL> {
  final TextEditingController pathController = TextEditingController();




  // functions: 
  //the organizer function
    void organize() async{
      
      if (pathController.text.trim().isEmpty) {
    setState(() {
      consoleOutput = "working directory is empty, choose a directory";
      });

      return;
  }


  String urlString="http://${Config.serverIp}/organize/";
  
  final dir = pathController.text.trim();

  // Show "organizing..." immediately
  setState(() {
    consoleOutput = "Organizing $selectedMode ...";
  });


  ProcessResult result;

  switch (selectedMode) {//enables cancel
    case "Smart Organizer":
      {
        urlString+="smart"+"?path="+dir;
        final url = Uri.parse(urlString);
        final response = await http.get(url);
         break;
      }

    case "By Type":
      urlString+="type"+"?path="+dir;
      final url = Uri.parse(urlString);
      final response = await http.get(url);
      break;

    case "By File Genre":
      urlString+="genre"+"?path="+dir;
      final url = Uri.parse(urlString);
      final response = await http.get(url);
      break;

    case "By Date"://enables cancel,
    { 
      
      urlString+="date"+"?path="+dir;
      final url = Uri.parse(urlString);
      final response = await http.get(url);
       break;
      }

    case "By Size":
  {
      final limits = await showSizeDialog(context);

      if(limits!=null)
    {  
      String limit1,limit2,limit3;
      limit1=limits["unit"].toString();
      limit2=limits["low"].toString();
      limit3=limits["high"].toString();

      urlString+="size"+"?path="+dir+"&unit="+limit1+"&low="+limit2+"&high="+limit3;
      final url = Uri.parse(urlString);
      final response = await http.get(url);
      
      break;}
      }
    case "undo":
      {
      urlString+="undo"+"?path="+dir;
      final url = Uri.parse(urlString);
      final response = await http.get(url);
       break;

      }

    default:
      return;
  }
    }
    



    //the grouper function
    void group() async{
       String urlString="http://${Config.serverIp}/organize/";
       switch (selectedGrouper) {
                          case "Quick Type Grouper":
                            runPackByType(urlString);
                            break;
                          case "Keywords Grouper":
                            runPackByKeywords(urlString);
                            break;
                          case "Date Interval Grouper":
                            runPackByDateInterval(urlString);
                            break;
                          case "Folder Keywords Grouper":
                            runPackByFolderKeywords(urlString);
                            break;
                          case "undo":
                            undo(urlString);
                            break;
                          
                        }
    }

//////////////////////  THE GROUPERS   ////////////////////////
  
//this func brings all the files with same one entered extension together
  void runPackByType(String urlstring) async{

    if (pathController.text.trim().isEmpty) {
    setState(() {
      consoleOutput = "working directory is empty, choose a directory";
    });
    return;
  }

    urlstring+="typeGrouper";
    if(extension.isEmpty || pathController.text.trim().isEmpty){
      setState(() {
      consoleOutput = "work directory / extension empty, make sure they both filled to proceed";
    });
      return;
    }


    if(overrideExisting)
    { 
      //await Process.run("smartOrganizer.exe",['--packByExt',pathController.text.trim(),extension.trim(),'true']);
      urlstring+="?path="+pathController.text.trim()+"&keywords="+extension.trim()+"&keywords=true";
      final url = Uri.parse(urlstring);
      final response = await http.get(url);
      
    }
    else{
     // await Process.run("smartOrganizer.exe",['--packByExt',pathController.text.trim(),extension.trim()]);
      urlstring+="?path="+pathController.text.trim()+"&keywords="+extension.trim();
      final url = Uri.parse(urlstring);
      final response = await http.get(url);
    }

  }



  //bring all the files withing the entered dates together
   void runPackByDateInterval(String urlstring) async{

    if (pathController.text.trim().isEmpty) {
    setState(() {
      consoleOutput = "working directory is empty, choose a directory";
    });
    return;
  }

    urlstring+="dateGrouper";
    if(startDate.isEmpty || endDate.isEmpty){
      setState(() {
        consoleOutput="date intervals missing, enter to proceed";
      });
      return;

    }

    if(overrideExisting)
       {   
          
          //lastProcess= await Process.start("smartOrganizer.exe",['--groupByDateInterval',"true",pathController.text.trim(),startDate,endDate]);
          urlstring+="?path="+pathController.text.trim()+"&keywords="+"true"+"&keywords="+startDate+"&keywords="+endDate;
          final url = Uri.parse(urlstring);
          final response = await http.get(url);
        }
  
    else{
      
          urlstring+="?path="+pathController.text.trim()+"&keywords="+startDate+"&keywords="+endDate;
          final url = Uri.parse(urlstring);
          final response = await http.get(url);
      
      }

   }
  





  //give it keywords and it will call exe keywords grouper
 void runPackByKeywords(String urlstring) async {

  if (pathController.text.trim().isEmpty) {
    setState(() {
      consoleOutput = "working directory is empty, choose a directory";
    });
    return;
  }
  if (keywords.trim().isEmpty) {
    setState(() {
      consoleOutput = "No keywords provided";
    });
    return;
  }

  urlstring+="keywordsGrouper";
  // Split by any whitespace
  List<String> keywordsVec = keywords.trim().split(RegExp(r"\s+"));

  if(overrideExisting){
      if(OR)
      {
       // await Process.run("smartOrganizer.exe", ['--keywordsGrouper',pathController.text.trim(),"true","or", ...keywordsVec]);
          urlstring+="?path="+pathController.text.trim()+"&keywords=true"+"&keywords=or";
          for(String word in keywordsVec){

            urlstring+="&keywords="+word;
          }

          final url = Uri.parse(urlstring);
          final response = await http.get(url);
      }
      else{
      //await Process.run("smartOrganizer.exe", ['--keywordsGrouper',pathController.text.trim(),"true", ...keywordsVec]);
      urlstring+="?path="+pathController.text.trim()+"&keywords=true";
          for(String word in keywordsVec){

            urlstring+="&keywords="+word;
          }

          final url = Uri.parse(urlstring);
          final response = await http.get(url);
      }
      }

    else{
    if(OR){
      //await Process.run("smartOrganizer.exe", ['--keywordsGrouper',pathController.text.trim(),"or", ...keywordsVec]);
      urlstring+="?path="+pathController.text.trim()+"&keywords=or";
          for(String word in keywordsVec){

            urlstring+="&keywords="+word;
          }
          final url = Uri.parse(urlstring);
          final response = await http.get(url);
    }
    else{ 
      // await Process.run("smartOrganizer.exe", ['--keywordsGrouper',pathController.text.trim(), ...keywordsVec]);
      urlstring+="?path="+pathController.text.trim();
          for(String word in keywordsVec){

            urlstring+="&keywords="+word;
          }
          final url = Uri.parse(urlstring);
          final response = await http.get(url);
    }
    }

}




  //give it keywords and it will call exe keywords grouper
 void runPackByFolderKeywords(String urlstring) async {


  if (pathController.text.trim().isEmpty) {
    setState(() {
      consoleOutput = "working directory is empty, choose a directory";
    });
    return;
  }

  urlstring+="folderGrouper";
  if (keywords.trim().isEmpty) {
    setState(() {
      consoleOutput = "No keywords provided";
    });
    return;
  }

  // Split by any whitespace
  List<String> keywordsVec = keywords.trim().split(RegExp(r"\s+"));

  overrideExisting=false;


    if(OR){
      //await Process.run("smartOrganizer.exe", ['--FolderGrouper',pathController.text.trim(),"or", ...keywordsVec]);
         urlstring+="?path="+pathController.text.trim()+"&keywords=or";
          for(String word in keywordsVec){

            urlstring+="&keywords="+word;
          }
          final url = Uri.parse(urlstring);
          final response = await http.get(url);
    }
    else{
      //  await Process.run("smartOrganizer.exe", ['--FolderGrouper',pathController.text.trim(), ...keywordsVec]);
         urlstring+="?path="+pathController.text.trim();
          for(String word in keywordsVec){

            urlstring+="&keywords="+word;
          }
          final url = Uri.parse(urlstring);
          final response = await http.get(url);
    }
    

}

void undo(String urlstring)async{
      urlstring+="undo"+"?path="+pathController.text.trim();
      final url = Uri.parse(urlstring);
      final response = await http.get(url);
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///                THE PROJECTOR FUNCTIONALITY, THE VARS AND THE CALL
String Currentfolder="";
var projectorMap;

//the projector 
void projector() async{

  if(pathController.text.trim().isEmpty){
    return;
  }

  //set first current folder as the path (its the main folder and has sub folders and sub files)
  

  String fixedPath = normalizePath(pathController.text.trim());
  Currentfolder=fixedPath;

  String urlString = "http://${Config.serverIp}/searchFile/projector?path=$fixedPath";

  final url = Uri.parse(urlString);
  final response = await http.get(url);
  final data = jsonDecode(response.body);

  // results هو نص JSON
  final rawResults = data["results"];
  projectorMap=rawResults;

}


    void _searchFile()async{
      
      if(pathController.text.trim().isEmpty)
     { 
      if(!_enableUniversalSearch || _searchQuery.text.trim().isEmpty )
      {
        setState(() {
          selectedRightPanel="none";
        });
        return;
      }}

      String urlStringBase="http://${Config.serverIp}/";
      String urlString=urlStringBase+"searchFile/";

      if(_enableUniversalSearch){
        urlString+="universal?";
      }
      else{
        urlString+="search?path=${pathController.text.trim()}";
      }
      print("starting search now ...");
      //the validation  before any search
      String urlValidation=urlStringBase+"validate";
      final url1=Uri.parse(urlValidation);
      //final response1 = await http.get(url1);

      final Pattern = RegExp(r"[,\s]+");
      List<String> keywords = _searchQuery.text.split(Pattern);
      keywords.removeWhere((word) => word.trim().isEmpty);
      for (String word in keywords){
          urlString+="&keywords="+word;
      }
      final url=Uri.parse(urlString);
      final response = await http.get(url);
      final data = jsonDecode(response.body);
     
     final List<dynamic> rawResults = data["results"];
     if(rawResults.isEmpty){
      setState(() {
        selectedRightPanel="none";
      });
      return;
     }
      _results.clear();

      for (var line in rawResults) {
        // line هو String مثل: "C:/folder/file.txt"
        _results.add({
          "filename": p.basename(line),
          "path": line,
        });
      }
     

      setState(() {
      selectedRightPanel="search";
      _buildRightPanel();  
      });
      
    }


 //for the organize by size, view the dialog to inout then proceed
 Future<Map<String, String>?> showSizeDialog(BuildContext context) async {
  String unit = "MB";
  String lowLimit = "";
  String highLimit = "";

  return await showDialog<Map<String, String>>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("By Size Organizer"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: unit,
                  items: ["MB", "GB"].map((u) {
                    return DropdownMenuItem<String>(
                      value: u,
                      child: Text(u),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      unit = val!;
                    });
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: "Lower Limit"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => lowLimit = val,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: "Upper Limit"),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => highLimit = val,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text("Cancel"),
                onPressed: () => Navigator.of(context).pop(null),
              ),
              ElevatedButton(
                child: const Text("Proceed"),
                onPressed: () {
                  Navigator.of(context).pop({
                    "unit": unit.toLowerCase(),
                    "low": lowLimit,
                    "high": highLimit,
                  });
                },
              ),
            ],
          );
        },
      );
    },
  );
}








          //the organizer variables
          bool overrideExisting = false;
          bool OR = false; //this bool is used in keywords grouper to bring the files that have either of the keywords
          String extension = "";
          String consoleOutput = "";
          String selectedMode = "By Type";
          final List<String> organizeModes = ["Smart Organizer","By Type", "By File Genre","By Date", "By Size","undo"];

          String startDate="";
          String endDate="";
          String keywords="";

          Process? lastProcess;

          String selectedGrouper = "Quick Type Grouper"; // default


          final List<String> grouperModes = [
          "Quick Type Grouper",
          "Keywords Grouper",
          "Date Interval Grouper",
          "Folder Keywords Grouper",
          "undo"
        ];


         Map<String , dynamic> folderMap={};
         String selectedRightPanel = "none";
         
        ///////////////////////////////////////////////////////////////////////////////////////////

        /// the searach engine variables
        
        final TextEditingController _searchQuery = TextEditingController();
        final TextEditingController _startDateController = TextEditingController();
        final TextEditingController _endDateController = TextEditingController();
        List<Map<String,dynamic>>_results = [];
        String _status = "";

        //bool validated=false;
        bool _enableUniversalSearch=false;
        //////////////////////////////////
        

  


Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT PANEL
          
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // PATH INPUT
                  Text("Enter path:", style: TextStyle(fontSize: 16)),
                  SizedBox(height: 8),
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: pathController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  // ORGANIZER SECTION
                  Text("Organizer Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Text("Mode: "),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedMode,
                        items: organizeModes
                            .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedMode = val!),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(onPressed: organize, child: Text("Start Organizer")),
                    ],
                  ),

                  SizedBox(height: 40),

                  // GROUPER SECTION
                  Text("Grouper Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                 CheckboxListTile(
                  title: const Text("Override Existing Files"),
                  value: overrideExisting,
                  onChanged: (val) => setState(() => overrideExisting = val!),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero, // يجعل النص ملصق لليسار
                ),

                  Row(
                    children: [
                      
                      Text("Mode: "),
                      SizedBox(width: 10),
                      DropdownButton<String>(
                        value: selectedGrouper,
                        items: grouperModes
                            .map((mode) => DropdownMenuItem(value: mode, child: Text(mode)))
                            .toList(),
                        onChanged: (val) => setState(() => selectedGrouper = val!),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // CONDITIONAL GROPER UI
                  if (selectedGrouper == "Quick Type Grouper")
                    SizedBox(
                      width: 200,
                      child: TextField(
                        decoration: InputDecoration(
                          labelText: "File Extension (e.g., exe)",
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) => extension = val,
                      ),
                    ),

                  if (selectedGrouper == "Keywords Grouper")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "Keywords",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => keywords = val,
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: OR,
                              onChanged: (val) => setState(() => OR = val ?? false),
                            ),
                            Text("Use OR instead of AND"),
                          ],
                        ),
                      ],
                    ),

                  if (selectedGrouper == "Date Interval Grouper")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "Start Date (DD-MM-YYYY)",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => startDate = val,
                          ),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "End Date (DD-MM-YYYY)",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => endDate = val,
                          ),
                        ),
                      ],
                    ),

                  if (selectedGrouper == "Folder Keywords Grouper")
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 200,
                          child: TextField(
                            decoration: InputDecoration(
                              labelText: "Keywords",
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (val) => keywords = val,
                          ),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: OR,
                              onChanged: (val) => setState(() => OR = val ?? false),
                            ),
                            Text("Use OR instead of AND"),
                          ],
                        ),
                      ],
                    ),

                  SizedBox(height: 10),
                  ElevatedButton(onPressed: group, child: Text("Start Grouper")),

                  SizedBox(height: 40),
                  // RIGHT PANEL CONTROLLER

                  Text("Right Panel Controller", 
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                  ),
                  SizedBox(height: 10),

                DropdownButton<String>(
                          value: selectedRightPanel,
                          items: [
                            DropdownMenuItem(value: "none", child: Text("None")),
                            DropdownMenuItem(value: "projector", child: Text("Projector")),
                            DropdownMenuItem(value: "search", child: Text("Search Results")),
                            DropdownMenuItem(value: "unpacker", child: Text("Unpacker")),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setState(() {
                              selectedRightPanel = val;
                            });

                            // ✅ جلب الأمر المناسب
                            switch (val) {
                              case "projector":
                                loadFullMap();
                                break;
                              case "unpacker":
                                loadFoldersForUnpacker(); // أو أي دالة تجلب البيانات
                                break;
                             
                            }
                          },
                        ),

                        SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                        if(selectedRightPanel=="unpacker")
                          {
                            unpackerFolders();
                            _buildRightPanel();
                          }
                        else if (selectedRightPanel=="projector")
                          {
                            loadFullMap();
                            showProjector();
                            _buildRightPanel();
                          }
                      },
                    child: Text("Run"),
                  ),


                  SizedBox(height: 40),
                  // SEARCH ENGINE SECTION
                  Text("Search Engine", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),

                  Row(
                    children: [
                      Text("Start Date: "),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _startDateController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "dd-mm-yyyy",
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    children: [
                      Text("End  Date: "),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          controller: _endDateController,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "dd-mm-yyyy",
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text("enable universal search"),
                      Checkbox(
                    value: _enableUniversalSearch,
                    onChanged: (bool? value) {
                      setState(() {
                        _enableUniversalSearch = value ?? false;
                      });
                    },
                  ),
                    ],
                  ),
                  Row(
                    children: [
                      
                      Text("Search: "),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 400,
                        child: TextField(
                          controller: _searchQuery,
                          decoration: InputDecoration(border: OutlineInputBorder()),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: _searchFile,
                        child: Text("Find Now"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),





          // RIGHT PANEL (EMPTY FOR NOW)
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: _buildRightPanel(),
            ),
          ),
        ],
      ),
    );
  }




//load the map and the sub folders
void loadFullMap() async{
  
  folderQue.clear();
  String fixedPath = normalizePath(pathController.text.trim());
  folderQue.add(fixedPath);
  String urlString = "http://${Config.serverIp}/searchFile/projector?path=$fixedPath";

  final url = Uri.parse(urlString);
  final response = await http.get(url);
  final data = jsonDecode(response.body);

  // results هو نص JSON
  final results=data["results"];

  final mapp=jsonDecode(results);

  projectorMap=mapp;

  Map<String, dynamic> folder_info = mapp[fixedPath];

  folderMap.clear();
  for(var path in folder_info["subfolders"]){
    String pathh=path.toString();
    folderMap[p.basename(pathh)] = pathh;
  }

  subFilesMap.clear();
  for(var path in folder_info["files"]){
    String pathh=path.toString();
    subFilesMap[p.basename(pathh)] = pathh;
  }
  setState(() {
    selectedRightPanel="projector";
  });

}


//
Map<String,dynamic> subFilesMap={};
void updateSubs(String newFolder){
  newFolder=normalizePath(newFolder);
  if(projectorMap.containsKey(normalizePath(newFolder))==false){
    return;
  }

  Map<String, dynamic> folder_info = projectorMap[newFolder];
    if (folderQue.isEmpty || folderQue.last != newFolder) {
    folderQue.add(newFolder);
  }
  folderMap.clear();
  
  if(folder_info.containsKey("subfolders"))
  { 
  for(var path in folder_info["subfolders"]){
    String pathh=path.toString();
    folderMap[p.basename(pathh)] = normalizePath(pathh);
  }}

  subFilesMap.clear();
  if(folder_info.containsKey("files"))
  {
  for(var path in folder_info["files"]){
    String pathh=path.toString();
    subFilesMap[p.basename(pathh)] = pathh;
  }}
 
  setState(() {
     print("the files size is this : ${subFilesMap.length}");
  });
}


//the folder queue, pop in return button click
List<String> folderQue=[];
void returnFunc(){
  //pop the folders queue and return
  if(folderQue.isNotEmpty){
    folderQue.removeLast();
  }
  if(folderQue.isEmpty){
    folderQue.add(normalizePath(pathController.text.trim()));
  }
  updateSubs(folderQue.last);
}


//right panel content functions
Widget showProjector(){ 
  return Scaffold(
    body: Column(
      children: [
        Row(children: [FloatingActionButton(onPressed: returnFunc,child: Icon(Icons.keyboard_return_rounded),)],),
        Text("The SubFolders: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),),
        Container(height: 200, child: subFolderwWidget()),
        SizedBox(height: 100,),
        Text("The SubFiles: ", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey),),
        Container(height: 200, child:  subFilesWidget())
      ],
    )
  );

}



// subfolders view
Widget subFolderwWidget() {
  if (folderMap.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          "No subfolders in this directory",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  return Scrollbar(
    thumbVisibility: true,
    child: ListView.builder(
      itemCount: folderMap.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final folderName = folderMap.keys.elementAt(index);
        final folderPath = folderMap.values.elementAt(index);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 2,
          child: ListTile(
            leading: const Icon(
              Icons.folder,
              color: Colors.amber,
              size: 28,
            ),
            title: Text(
              folderName,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              folderPath,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              tooltip: "Open folder",
              onPressed: () => updateSubs(folderPath),
            ),
            onTap: () => updateSubs(folderPath), // ✅ النقر على البطاقة
          ),
        );
      },
    ),
  );
}

// sub files view
Widget subFilesWidget() {
  if (subFilesMap.isEmpty) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          "No files in this directory",
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ),
    );
  }

  return Scrollbar(
    thumbVisibility: true,
    child: ListView.builder(
      itemCount: subFilesMap.length,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (context, index) {
        final fileName = subFilesMap.keys.elementAt(index);
        final filePath = subFilesMap.values.elementAt(index);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          elevation: 1,
          child: ListTile(
            leading: const Icon(
              Icons.insert_drive_file,
              color: Colors.blueGrey,
              size: 24,
            ),
            title: Text(
              fileName,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
            subtitle: Text(
              filePath,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ),
        );
      },
    ),
  );
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//the search widget 
Widget showSearchResults() {
  if (_results.isEmpty) {
    return const Center(
      child: Text(
        "No results found.",
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  return Expanded(
    child: ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final item = _results[index];
        final filename = item["filename"];
        final fullpath = item["path"];

        return ListTile(
          title: Text(filename),
          subtitle: Text(fullpath),
        );
      },
    ),
  );
}




//exclude a folder, remove it from the folder map
  void excludeFolder(String folderName) {
  setState(() {
    folderMap.remove(folderName);
  });
}


//the unpacker widget
Widget showUnpacker() {
  return Scaffold(
    body: ListView.builder(
      itemCount: folderMap.length,
      itemBuilder: (context, index) {
        final folderName = folderMap.keys.elementAt(index);
        return ListTile(
          title: Text(folderName),
          trailing: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => excludeFolder(folderName),
          ),
        );
      },
    ),
  );
}



//the normalized path in the unified C:\\users\\downloads
String normalizePath(String path) {
  // تحويل كل / إلى \\ (سلاشين)
  String path1=path.replaceAll("//", "\\\\");
  List<String> pathParts=path1.split("\\\\");
  if(pathParts.length<2) return pathParts[0];
  String path2=pathParts[1].replaceAll("/", "\\\\");
  path1=pathParts[0]+"\\\\"+path2;
  path1=path1.replaceAll("\\\\", "\\");
  return path1;
}



//load the folders for the unpcker
void loadFoldersForUnpacker() async{
   String rawPath = pathController.text.trim();

  if (rawPath.isEmpty) {
    setState(() {
      selectedRightPanel = "none";
    });
    return;
  }

  String fixedPath = normalizePath(rawPath);

  String urlString = "http://${Config.serverIp}/searchFile/projector?path=$fixedPath";

  final url = Uri.parse(urlString);
  final response = await http.get(url);
  final data = jsonDecode(response.body);

  // results هو نص JSON
  final results=data["results"];

  final mapp=jsonDecode(results);

  projectorMap=mapp;

  Map<String, dynamic> folder_info = mapp[fixedPath];

  folderMap.clear();
  for(var path in folder_info["subfolders"]){
    String pathh=path.toString();
    folderMap[p.basename(pathh)] = pathh;
  }


    setState(() {
      selectedRightPanel = "unpacker";
    });
}


//unpack folders ... 
void unpackerFolders() async {
  String pathUrl="";
   String urlString = "http://${Config.serverIp}/organize/unpack?path=";
    for(String path in folderMap.values){
          pathUrl="";
          path=Uri.encodeComponent(path);
          pathUrl=urlString+=path;
          final url = Uri.parse(pathUrl);
          final response = await http.get(url);
    }
  }




Widget _buildRightPanel() {
  switch (selectedRightPanel) {
    case "projector":
      return showProjector();
    case "search":
      return showSearchResults();
    case "unpacker":
    { 
     return showUnpacker();
    }
    default:
      return Center(
        child: Text(
          "Right Panel (Projector / Search Results / Unpacker)",
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      );
  }
}



}