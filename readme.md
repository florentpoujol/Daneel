[craftstudio]: http://craftstud.io

# Daneel

Daneel is a scripting framework written in [Lua](http://www.lua.org) for [CraftStudio][] that bring new functionalities, extend and render more flexible to use the API as well as sweeten and shorten the code you write.


## Documentation

[http://daneel.florentpoujol.fr/docs](http://daneel.florent-poujol.fr/docs) 


## Installation

[Download](http://daneel.florentpoujol.fr/download/Daneel_v1.5.0.zip) then import in your project whatever scripts you need from `Daneel_v1.5.0.cspack`.  
[Check the documentation](http://daneel.florent-poujol.fr/docs/setup) for more information on the setup.


## Support

If you have got any trouble or question, [leave a support ticket on GitHub](https://github.com/florentpoujol/Daneel), or contact me :

- florent.poujol@gmail.com
- [@FlorentPoujol](https://twitter.com/FlorentPoujol) 

Or leave a support topic in CraftStudio's community forums : 

- [English forum](http://www.craftstudioforums.net/index.php?forums/help-with-scripting.30)
- [French forum](http://www.craftstudio.fr/forum/viewforum.php?f=4)


## Repo structure

The main `.lua` files are in the `framework` folder.  
The scripts at the root of the folder are 'global' and don't need to be added as scripted behavior on game objects (contrary to the one found in the `scripted behaviors` folder).

The `daneelcomplete/DaneelComplete.lua` script (and its minified version) is an aggregation of all the 'global' scripts at the root of the `framework` folder.  


## Licence

Daneel is published under the MIT license.

Copyright © 2013-2014 Florent Poujol <forent.poujol@gmail.com>.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF
ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED
TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT
SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE
OR OTHER DEALINGS IN THE SOFTWARE.
