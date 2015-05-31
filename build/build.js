/*
Concatenate the files at the root of the "src" folder in a big "build/Daneel.lua" file 
then minify it in "build/Daneel.min.lua".

How to use :

- Install Node Js and Luamin ( https://github.com/mathiasbynens/luamin )
- Copy/paste this script in the same folder as Luamin, or another one if Luamin is installed globally.    
- Launch a Node Js cmd prompt, nagivate to where this script is then run it with "node [nameofthescript]" 
*/

var luamin = require("luamin");
var fs = require("fs");

var root = "F:/Development/CraftStudio/Daneel/";
var readRoot = root+"src/";
var writeRoot = root+"build/";

var fileNames = [
    "Lua",
    "Main",
    "CraftStudio",
    "GUI",
    "Draw",
    "Color",
    "Tween",
]; // let the Tween script at the end of the array

var completeFilePath = writeRoot+"Daneel.lua";
var completeMinFilePath = writeRoot+"Daneel.min.lua";

var fileIndex = -1;
var sDate = "-- Generated on "+ new Date().toString() +"\n";

// read all files, append their non-minified content in completeFilePath
// then minify it

var appendToCompleteFile = function(err, data) {
    if (err) {
      console.log(err);
      return;  
    }

    // data is the text content
    // append the  to the main file
    fs.appendFile( completeFilePath, data+"\n", function(err) {
        if (err) {
          console.log(err);
          return;  
        }

        main();
    } );    
};


function main() {
    if (fileIndex == -1) {
        console.log( "Aggregation of the files begins" );
        
        // create the complete (non-min) file
        fs.writeFile( completeFilePath, sDate, function(err) {
            if (err) {
              console.log(err);
              return;  
            } 
        } );
    }
    
    var fileToReadName = fileNames[++fileIndex];

    if (fileToReadName === undefined) {
        // no more files to read, time to minify
        console.log( "Aggregation of the files completed" );
        
        fs.readFile( completeFilePath, "utf8", function(err, data) {
            if (err) {
              console.log(err);
              return;  
            }

            console.log( "Minifying begins" );
            
            var index = data.indexOf( "-- Easing equations" );
            easing = data.substring( index, data.length );
            data = data.substring( 0, index-1 );
            var minData = sDate + luamin.minify( data );
            minData += "\n"+easing;
            
            console.log( "Minifying completed" );
            console.log( "Writting complete min file at path: "+completeMinFilePath );

            fs.writeFile( completeMinFilePath, minData, function(err) {
                if (err) {
                  console.log(err);
                  return;  
                }

                console.log("Complete min file written.");
            } );
        } );
    }
    else {
        // read a file and append it to the complete file
        var fileToReadPath = readRoot+fileToReadName+".lua";
        console.log("Reading file at path: "+fileToReadPath);

        fs.readFile( fileToReadPath, "utf8", appendToCompleteFile );
    }
}
main();
