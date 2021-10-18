# Custom Plasma Lockscreen Win 10 style

## Modifications
* Display unread gmail messages count, current weather temp and conditions
* kb/mouse movement, hide clock and status info, show login/password Ui


![Plasma Lockscreen](Screenshot_20211017_154639.png)
![Plasma Lockscreen](Screenshot_20211017_154629.png)

### How it works:
For security reasons, kscreenlocker does not allow internet acesss, 
this is a hack using local files as JS variables <br/>
Modified Breeze plasma qml files to get the desired effects. Designed for 1920x1080 screens. <br/>
Using javacript node and python to create JS variables written to file system <br/>
The JS variables are used within qml losckreen files and systemd scripts to update them. <br/>
Using qml js functions XMLHttpRequest to read .json data files with a timer, systemd to update the .json data perodically <br/>
Weather icons: place in -  /home/user-name/.local/share/plasma/look-and-feel/YourTheme/contents/icons <br/>

Copy qml files to your theme folder in /home/user-name/.local/share/plasma/look-and-feel/YourTheme/contents/ <br/>
   lockscreen folder  - LockScreen.qml, LockScreenUi.qml, MainBlock.qml - /home/user-name/.local/share/plasma/look-and-feel/YourTheme/contents/lockscreen <br/>
   components folder - Clock.qml, UserDelegate.qml, WallpaperFader.qml <br/>
   
### Test it with -  /usr/lib/kscreenlocker_greet --testing --theme $HOME/.local/share/plasma/look-and-feel/MyBreeze

### See this for more info https://github.com/txhammer68/plasma-Lockscreen-nest-hub/blob/master/readme.md#custom-plasma-lockscreen
