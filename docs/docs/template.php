<!--
$pageTitle  is the CamelCased name of the file
$filePath   is the relative file path
$indexUrl   is the absolute url of the root folder
-->
<html>
    <head>       
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
        <meta name="description" content="Daneel is a scripting framework written in Lua for CraftStudio that bring new functionalities, extend and render more flexible to use the API as well as sweeten and shorten the code you write.">
        <meta name="keywords" content="Daneel, CraftStudio, framework, game, Lua, library">
        <meta name="robots" content="index,follow">

        <title><?php echo $pageTitle; ?> - Daneel2 : a framework for CraftStudio</title>

        <link rel="stylesheet" type="text/css" href="<?php echo $indexUrl; ?>/assets/css/style_v35.css">
        <link rel="stylesheet" type="text/css" href="<?php echo $indexUrl; ?>/assets/css/daneeldoc.css">
        <script language="javascript" type="text/javascript" src="<?php echo $indexUrl; ?>/assets/js/modernizr-2.5.3.min.js"></script>
    </head>
    <body onload="prettyPrint()">

        <div class="wrapper">
            <header>
                <div id="right-header">
                    <p id="download">
                        <a href="/download/Daneel_v1.5.0.zip" title="Download the last version of Daneel">Download</a> <br>
                        <small>v1.5.0</small>
                    </p>

                    <p id="github">
                        <a href="https://github.com/florentpoujol/Daneel" title="Daneel on GitHub">
                            Daneel on GitHub 
                            <img src="<?php echo $indexUrl; ?>/assets/img/github_logo_empty.png" alt="logo GitHub">
                        </a>
                    </p>
                </div>

                <img src="<?php echo $indexUrl; ?>/img/Daneel_logo_nobackground.png" alt="Daneel logo" height="75px" class="logo">

                <h1>Daneel</h1>
                <h3>A framework for <a href="http://craftstud.io">CraftStudio</a></h3>
                <div class="clearfloat"></div>
            </header>
            
            <div role="main" class="main">
                <aside class="sidebar">
                    <?php echo GetHtmlFromMarkdownFile( 'files/sidebar.md' ); ?>
                </aside>
                <div class="content">
                    <?php
                    if ( EndsWith( $filePath, ".md" ) )
                        echo GetHtmlFromMarkdownFile( $filePath );
                    elseif ( EndsWith( $filePath, ".php" ) )
                        include $filePath;
                    else
                        echo file_get_contents( $filePath );
                    ?>
                </div>
            </div>

            <footer>
                Powered by <a href="https://github.com/florentpoujol/MarkdownStaticSite" title="Go to Markdown Static Site GitHub page">Markdown Static Site</a>. Go back to <a href="http://florentpoujol.fr" title="Go back to Florent Poujol's website">FlorentPoujol.fr</a>.
            </footer>
        </div>

        <script language="javascript" type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js"></script>
        <script language="javascript" type="text/javascript" src="<?php echo $indexUrl; ?>/assets/js/prettify.js"></script>
        <script language="javascript" type="text/javascript" src="<?php echo $indexUrl; ?>/assets/js/lang-lua.js"></script>
        <script language="javascript" type="text/javascript" src="<?php echo $indexUrl; ?>/assets/js/scroll.js"></script>

        <?php
        if ( strpos( $indexUrl, "localhost" ) === false )
            include "googleanalytics.php";
        ?>
    </body>
</html>
