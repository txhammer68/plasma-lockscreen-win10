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

property int today:Qt.formatDate(timeSource.data["Local"]["DateTime"],"MMdd")
property var events:{
0101:"🎊 New Year's Day",
0116:"🎂 Johnny Taylor's Birthday",
0117:"🎂 Chuck Coxie's Birthday",
0202:"Groundhog Day",
0211:"🎂 Dad's Birthday",
0214:"💘 Valentine's Day",
0220:"🎂 Travis Mitchell's Birthday",
0221:"🇺🇸 Presidents' Day",
0302:"🎂 Joe Childers's III Birthday",
0311:"🎂 Zach Taylor's Birthday",
0315:"🎂 Earl Estep's Birthday",
0317:"🍀St. Patricks day",
0318:"🎂 Katie Taylor's Birthday",
0322:"🎂 Kathy Clark's Birthday",
0401:"April Fools' Day",
0413:"🎂 Nick Taylor's Birthday",
0422:"♻ Earth Day",
0428:"🎂 Bridget Hemmeline's Birthday",
0504:"🎂 Chase Taylor's Birthday",
0505:"🇲🇽 Cinco De Mayo",
0614:"🇺🇸 Flag Day",
0623:"🎂 David Mounts's Birthday",
0704:"🇺🇸 Independence Day",
0805:"🎂 Jennifer Taylor's Birthday",
0809:"🎂 Natalie Taylor's Birthday",
0904:"🎂 Sheri McNiel's Birthday",
0906:"🎂 Christine Guidroiz's Birthday",
0911:"🇺🇸 September 11th (Patriot Day)",
0920:"🎂 Paul Jr.'s Birthday",
0921:"🎂 Diane Tweedle's Birthday",
0923:"🎂 Misty Guidroz's Birthday",
1003:"🎂 Murline Staley's Birthday",
1009:"🎂 Brad,Nathan Brenda Taylor's Birthdays",
1026:"🎂 Cindy Mitchell's Birthday",
1031:"🎃 Halloween",
1118:"🦃 Thanksgiving Day",
1124:"🎂 Paul Clark's III Birthday",
1212:"🎂 Geoff Simon's III Birthday",
1216:"🎂 Andrew Taylor's Birthday",
1224:"🎅🏻 Christmas Eve",
1225:"🎄 Christmas Day",
1231:"🎊 New Years Eve"
}

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
               current_weather_conditions.temp = data.temperature;
               current_weather_conditions.desc = data.cloudCoverPhrase;
               wIcon.wIconurl="../icons/"+data.iconCode+".png"
               response=0
           }
       }
       xhr.send(); // begin the request
   }
   
   function readForecastFile(fileUrl){  // read weather info from file
       var xhr = new XMLHttpRequest;
       xhr.open("GET", fileUrl); // set Method and File
       xhr.onreadystatechange = function () {
           if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
               var response = xhr.responseText;
               var data = JSON.parse(response);
               data=data.narrative[0]
               current_weather_conditions.forecast = data
               response=0
           }
       }
       xhr.send(); // begin the request
   }

   
   function getOrdinal(n) {            // assigns superfix to date
        var s=["th","st","nd","rd"],
        v=n%100;
        return (s[(v-20)%10]||s[v]||s[0]);
        }
        property var nth:getOrdinal(Qt.formatDate(timeSource.data["Local"]["DateTime"],"d"))
        
   Component.onCompleted: {
        readWeatherFile("/tmp/weather.json")
        readForecastFile("/tmp/forecast.json")
    }
Rectangle {
    width:root.width
    height:root.height
    color:"black"
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
        topPadding:10
        bottomPadding:10
        anchors.leftMargin:10
        anchors.left:time.left
        anchors.top:time.bottom

        textFormat: Text.RichText
        text: Qt.formatDate(timeSource.data["Local"]["DateTime"],"dddd, MMMM  d")// +"<sup>"+nth+"</sup>"
        color:font_color
        renderType: Text.QtRendering
        font {
            pointSize: 28
            // family: config.displayFont
            family: font_style2
        }
    }
    
    Text {
            text:"<sup>"+nth+"</sup>"
            color: font_color
            textFormat: Text.RichText
            font.pointSize: 28
            anchors.left:date.right
            anchors.top:date.top
            renderType: Text.QtRendering
    }


     Text {
        id:ev
        text:events[today]
        color:font_color
        anchors.top:date.bottom
        anchors.left:date.left
        // color: ColorScope.textColor
        antialiasing : true
            font {
            pointSize: 20
           family: font_style2
            italic:true
                }
        visible: events[today] === undefined ? false : true
        height: ev.visible ? date.height*.7 : 0  // hide events if blank
       }

     Image {
       id: wIcon
       property var wIconurl:""
       anchors.top:ev.bottom
       anchors.left:ev.left
       asynchronous : true
       cache: false
       source: wIconurl
       smooth: true
       sourceSize.width: 48
       sourceSize.height: 48
    }

        Text {
        id:current_weather_conditions
        anchors.top:wIcon.top
        topPadding:5
        bottomPadding:10
        textFormat: Text.RichText
        anchors.left:wIcon.right
        anchors.leftMargin:10
        property var temp:""
        property var desc:""
        property var forecast:""
        text:temp+"°  "+desc+"<br><&nbsp;> "+forecast
        font.family: font_style2
        font.pointSize: 20
        font.capitalization: Font.Capitalize
        color:font_color
        // color: ColorScope.textColor
        antialiasing : true
        }
        
        Timer {                  // timer to trigger update for weather temperature
        id: timerTemp
        interval: 16 * 60 * 1000 // every 16 minutes
        running: true
        repeat:  true
        onTriggered: {
            root.startTime=0  // restart counter since last update
            readWeatherFile("/tmp/weather.json")
            readForecastFile("/tmp/forecast.json")
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
                readWeatherFile("/tmp/weather.json")
                readForecastFile("/tmp/forecast.json")
        }
     }   
}
   
    DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }
}
