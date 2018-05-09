# WordPress-script-installation
Installation script for wordpress on linux debian 8.1 server<br>

### To start the script you have to grant the execution rights

`chmod u+x wordpress.sh`

### To start the script<br>

`./worpress.sh`

### to force the reinstallation of all packages<br>

`./wordpress.sh -f`

### Global variable at the beginning of the file<br>

`DatabasePass="test"` password of the admin database wordpress <br>

`Directory="/var/www/html/index.html"` by default<br>

`admin="word"` name of the admin database wordpress <br>

`name="wordly"` name of the database wordpress <br>

`email="meslien.jonathan@gmail.com"` adress mail <br> 

`url="wp.mywebchef.org"` alias domain name for development <br>

`urltwo="mywebchef.org"` domain name for development <br>

`folder="/var/www/html/toto"` virtualhost folder <br>
