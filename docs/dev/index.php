<?php
// path inside which lies your markdown files
$markdownFilesPath = "files";

// default path/name of the .md file (relative to $markdownFilesPath) to read when no path is supplied in the url
$path = "welcome";

// Tell wether mod rewrite is use to remove "index.php?" from the url
$useModRewrite = true;

// type of file that can be accessed without specifying the extension
$rewriteExtensions = array( "md", "html", "php" );

// list of redirections - old => new
$redirect = array();

if ( file_exists( "config.json" ) ) {
    $config = json_decode( file_get_contents( "config.json" ), true );
    $markdownFilesPath = $config["markdownFilesPath"];
    $path = $config["defaultPath"];
    $useModRewrite = $config["useModRewrite"];
    $rewriteExtensions = $config["rewriteExtensions"];
    $redirect = $config["redirect"];
}


//-----------------------------------------

$queryString = trim( $_SERVER["QUERY_STRING"], "/" ); // GET part, after index.php?
// This the path of the file the user want to read
// ie : file1/file2

$relFilePath = str_replace( $queryString, "", $_SERVER["REQUEST_URI"] ); 
// request uri is the full string after the domain name.  ie:  /folder1/index.php?home
// $relFilePath is the path (begins by a slash) after the domain name, up until the file name . ie: /folder1/index.php

$indexUrl = "http://".$_SERVER['HTTP_HOST'].$relFilePath;
$indexPath = trim( str_replace( array("index.php", "?"), "", $indexUrl ), "/");

if ( !$useModRewrite && !strpos($indexUrl, "index.php?") )
    $indexUrl .= "index.php?";

if ($queryString != "")
    $path = $queryString;
else // index, redirect toward default path
    header( "Location: ".$indexUrl.$path );

$pathInfo = pathinfo( $path );
$pageTitle = ucwords( str_replace( "-", " ", $pathInfo['filename'] ) );
$filePath = $markdownFilesPath."/".$path;

if ( !isset( $pathInfo['extension'] ) ) {
    foreach ($rewriteExtensions as $ext) {
        if ( file_exists( $filePath.".".$ext ) ) {
            $filePath .= ".".$ext;
            break;
        }
    }
}

if ( !file_exists( $filePath ) ) {
    if (isset($redirect[$path])) {
        header( "Location: ".$indexUrl.$redirect[$path] );
    }

    $filePath = "404.php";
    $title = "404";
}


//-----------------------------------------

function EndsWith( $haystack, $needle ) {
    return $needle === "" || substr( $haystack, -strlen( $needle ) ) === $needle;
}

function GetHtmlFromMarkdownFile( $filePath ) {
    if ( !file_exists( $filePath ) )
        return "File '$filePath' doesn't exists !";

    return Markdown( file_get_contents( $filePath ) ); // v1.0.1
}

require_once "lib/markdownv1.0.1.php";

include "template.php";
