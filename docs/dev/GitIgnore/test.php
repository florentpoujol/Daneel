<?php
require_once "docs/lib/MarkdownInterface.php";
require_once "docs/lib/Markdown.php";
echo Michelf\Markdown::defaultTransform( file_get_contents( 'docs/files/core/functionreference.md' ) );