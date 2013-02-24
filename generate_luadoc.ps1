$files = Get-ChildItem .\
foreach( $file in $files ) {
    luadoc_start.bat "$file"
}