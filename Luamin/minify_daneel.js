
console.log( "daneel start" );

var luamin = require("luamin")
var fs = require("fs")

var root = "F:/Development/CraftStudio/Daneel/";
var writeRoot = root+"Luamin/";

var fileNames = [
    "Lua",
    "Daneel",
    "CraftStudio",
    "GUI/GUI",
    "Draw/Draw",
    "Color",
    "Tween/Tween",
]; // let the Tween script at the end of the array

var completeFilePath = writeRoot+"DaneelComplete.lua"
var completeMinFilePath = writeRoot+"DaneelComplete.min.lua"

var fileIndex = -1;

// read all files, append their non-minified content in completeFilePath
// then minify it

var appendToCompleteFile = function(err, data) {
    // data is the text content
    if (err) {
      console.log(err);
      return;  
    }

    // append the  to the main file
    fs.appendFile( completeFilePath, data+"\n", function(err) {
        if (err) {
          console.log(err);
          return;  
        }

        main()
    } );    
}


function main() {
    if (fileIndex == -1) {
        console.log( "Aggregation of the files begins" );
        
        // create the complete (non-min) file
        fs.writeFile( completeFilePath, "", function(err) {
            if (err) {
              console.log(err);
              return;  
            } 
        } );
    }
    
    var fileToReadName = fileNames[++fileIndex];

    // no more files to read, time to minify
    if (fileToReadName === undefined) {
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
            var minData = luamin.minify( data );
            minData += "\n"+easing;
            
            console.log( "Minifying completed" );
            console.log( "Writting complete min file at path: "+completeMinFilePath );

            fs.writeFile( completeMinFilePath, minData, function(err) {
                if (err) {
                  console.log(err);
                  return;  
                }

                console.log("Complete min file written.")
            } );
            
        } )

        return;
    }

    var fileToReadPath = root+fileToReadName+".lua";
    console.log("Reading file at path: "+fileToReadPath);

    // read and append to complete file
    fs.readFile( fileToReadPath, "utf8", appendToCompleteFile )
}
main();


console.log( "daneel end" );

/*
//code commented on 18 october 2014 11h41
var readCalback = function(err, data) {
    if (err) {
      console.log(err);
      return;  
    }

    // write the minification to a single file
    var fileName = files[fileIndex];
    if (fileName.indexOf("/") != -1 || fileName.indexOf("\\") != -1) {
        fileName = fileName.replace(/^.+[\\/]/, "");
        // console.log(fileName);
    }

    // minify
    var minData = "";

    if (fileName == "Tween") {
        var index = data.indexOf( "-- Easing equations" );
        easing = data.substring( index, data.length );
        data = data.substring( 0, index-1 );
        minData = luamin.minify( data );
        minData += "\n"+easing;
    } else {
        minData = luamin.minify( data );
    }


    var singleFilePath = writeRoot+fileName+".min.lua";
    
    fs.writeFile( singleFilePath, minData, function(err) {
        if (err) {
          console.log(err);
          return;  
        }
    } );

    // append the minification to the main file
    fs.appendFile( completeFilePath, minData+"\n", function(err) {
        if (err) {
          console.log(err);
          return;  
        }

        readAndAppend()
    } );    
}


function readAndAppend() {
    if (fileIndex == -1) {
        console.log( "Minifying begin" );
        fs.writeFile( completeFilePath, "", function(err) {
            if (err) {
              console.log(err);
              return;  
            } 
        } );
    }
   
    var readFileName = files[++fileIndex];
    if (readFileName === undefined) {
        console.log( "Minifying completed" );
        return;
    }

    var readFilePath = root+readFileName+".lua";
    
    // first, add one line with the name of the file
    fs.appendFile( completeFilePath, "-- "+readFileName+"\n", function(err) {
        if (err) {
          console.log(err);
          return;  
        }

        // read the non minified .lua file
        fs.readFile( readFilePath, "utf8", readCalback )
    } );
}
readAndAppend();
*/

/*
    var writeSingleFile = function() {
        fs.writeFile( singleFilePath, minData, function(err) {
            if (err) {
              console.log(err);
              return;  
            }
        } );

        // append the minification to the main file
        fs.appendFile( completeFilePath, minData+"\n", function(err) {
            if (err) {
              console.log(err);
              return;  
            }

            readAndAppend()
        } );
    };

    // check if the directory exists. if not, create it 
    fs.exists( singleFilePath, function( exists ) {
        if (!exists) {
            var dirPath = singleFilePath.replace(/[^\\/]+\.lua/, "");
            // console.log("dir path", dirPath);
            fs.mkdir( dirPath, function() {
                if (err) {
                  console.log(err);
                  return;  
                }

                writeSingleFile();
            } );
        } else {
            writeSingleFile();
        }
    } );*/
