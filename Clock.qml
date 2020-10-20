/*
 *   Copyright 2016 David Edmundson <davidedmundson@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

// custom clock for plasma lockscreen ala windows 10 style
// shows time,weather,email, in lower left corner
// /usr/lib/x86_64-linux-gnu/libexec/kscreenlocker_greet --testing --theme /home/matt/.local/share/plasma/look-and-feel/DigiTech3

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import org.kde.plasma.core 2.0


Item {
id: root // timer for suspend-resume update
property double startTime: 0
property int secondsElapsed: 0
function restartCounter() {
root.startTime = 0;
}
function timeChanged() {
if(root.startTime==0)
{
root.startTime = new Date().getTime(); //returns the number of milliseconds since the epoch (1970-01-01T00:00:00Z);
}
var currentTime = new Date().getTime();
root.secondsElapsed = (currentTime-startTime)/1000;
}
    property var font_color:"white"
    property var font_style1:"Michroma"
    property var font_style2:"Noto Sans"
    
    function readWeatherFile(fileUrl){  // read weather info from file
       var xhr = new XMLHttpRequest;
       xhr.open("GET", fileUrl); // set Method and File
       xhr.onreadystatechange = function () {
           if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
               var response = xhr.responseText;
               var data = JSON.parse(response);
               current_weather_conditions.temp = data.temp;
               current_weather_conditions.desc = data.conditions;
               wIcon.wIconurl  = data.icon;
           }
       }
       xhr.send(); // begin the request
   }

   function readEmailFile(fileUrl){  // read icon code from file
       var xhr = new XMLHttpRequest;
       xhr.open("GET", fileUrl); // set Method and File
       xhr.onreadystatechange = function () {
           if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
               var response = xhr.responseText;
               email_count.email  = response;
           }
       }
       xhr.send(); // begin the request
   }
   
   Component.onCompleted: {
        readWeatherFile("/home/matt/.local/share/plasma/look-and-feel/DigiTech/contents/code/weather.json")
        readEmailFile("/home/matt/.local/share/plasma/look-and-feel/DigiTech/contents/code/gmail.txt")
    }
   
    Text {
        id:time
        anchors.top:root.top
        bottomPadding:-10
        leftPadding:-10
        text: Qt.formatTime(timeSource.data["Local"]["DateTime"],"h:mm ap").replace("am", "").replace("pm", "")
        color: font_color
        renderType: Text.QtRendering
        font {
            pointSize: 76
            family: font_style1
        }
    }
    Text {
        id:date
        topPadding:20
        bottomPadding:10
        anchors.leftMargin:20
        anchors.left:time.left
        anchors.top:time.bottom
        function getOrdinal(n) {            // assigns superfix to date
        var s=["th","st","nd","rd"],
        v=n%100;
        return (s[(v-20)%10]||s[v]||s[0]);
        }
        property var nth:getOrdinal(Qt.formatDate(timeSource.data["Local"]["DateTime"],"d"))
        textFormat: Text.RichText
        text: Qt.formatDate(timeSource.data["Local"]["DateTime"],"MMMM  d")+"<sup>"+nth+"</sup>"
        color: font_color
        renderType: Text.QtRendering
        font {
            pointSize: 36
            // family: config.displayFont
            family: font_style2
        }
    }

     Image {
       id: wIcon
       property var wIconurl:""
       anchors.top:date.bottom
       anchors.left:date.left
       asynchronous : true
       cache: false
       source: wIconurl
       smooth: true
       sourceSize.width: 64
       sourceSize.height: 64
    }

        Text {
        id:current_weather_conditions
        anchors.top:date.bottom
        topPadding:10
        bottomPadding:10
        anchors.left:wIcon.right
        anchors.leftMargin:10
        property var temp:""
        property var desc:""
        text:temp+desc
        font.family: font_style2
        font.pointSize: 24
        font.capitalization: Font.Capitalize
        color: font_color
        // color: ColorScope.textColor
        antialiasing : true
        }
        
        Timer {                  // timer to trigger update for weather temperature
        id: timerTemp
        interval: 21 * 60 * 1000 // every 20 minutes
        running: true
        repeat:  true
        onTriggered: {
            root.startTime=0  // restart counter since last update
            readWeatherFile("/home/matt/.local/share/plasma/look-and-feel/DigiTech/contents/code/weather.json")
            readEmailFile("/home/matt/.local/share/plasma/look-and-feel/DigiTech/contents/code/gmail.txt")
        }
        }
        
    Timer{                  // timer to trigger update after wake from suspend mode
       id: suspend
       interval: 60*1000 ///delay 60 secs for suspend to resume
       running: true
       repeat:  true
       onTriggered: {
                root.timeChanged()
               if (root.secondsElapsed > 1261) {
                readWeatherFile("/home/matt/.local/share/plasma/look-and-feel/DigiTech/contents/code/weather.json")
                readEmailFile("/home/matt/.local/share/plasma/look-and-feel/DigiTech/contents/code/gmail.txt")
        }
     }   
}
    Image {
        id:email_icon
        anchors.top:wIcon.bottom
        anchors.left:date.left
        anchors.topMargin:10
        anchors.leftMargin:10
        source: "/home/matt/.local/share/plasma/look-and-feel/DigiTech/contents/icons/email3.png"
        smooth: true
        sourceSize.width: 48
        sourceSize.height: 48
        }
      
      Text {
        id:bubble
        anchors.topMargin: -15
        anchors.leftMargin:-5
        anchors.top:email_icon.top
        anchors.left:email_icon.right
        text: "🔴"
        font.family: font_style2
        font.pointSize:22
        color: font_color
        antialiasing : true
        renderType: Text.QtRendering
    }
      
      Text {
        id:email_count
         //anchors.topMargin:-20
        topPadding:22
        //anchors.leftMargin:-20
         //anchors.left:bubble.right
         //anchors.horizontalCenter:bubble.horizontalCenter
         anchors.centerIn: bubble
         //anchors.horizontalCenter:gold.horizontalCenter;
         //anchors.top:bubble.bottom
        //anchors.left:bubble.left
        property var email:""
        text: email
        font.family: font_style2
        font.pointSize:12
        color: font_color
        antialiasing : true
        renderType: Text.QtRendering
    }
   
    DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }
}
