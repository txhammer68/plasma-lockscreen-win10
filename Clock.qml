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

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5
import org.kde.plasma.core 2.0
import "/home/hammer/.local/share/plasma/look-and-feel/DigiTech/contents/code/gmail.js" as Gmail

Item {
    id:root
    property var font_color:"whitesmoke"
    property var font_style1:"Michroma"
    property var font_style2:"Noto Sans"
    
    function readIconFile(fileUrl){  // read icon code from file
       var xhr = new XMLHttpRequest;
       xhr.open("GET", fileUrl); // set Method and File
       xhr.onreadystatechange = function () {
           if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
               var response = xhr.responseText;
               wIcon.wIconurl  = response;
               return response;
           }
          }
       xhr.send(); // begin the request
      // return response;
      }
      
      
       function readTempFile(fileUrl){     // read current weather temperature from text file
            var xhr = new XMLHttpRequest;
            xhr.open("GET", fileUrl); // set Method and File
            xhr.onreadystatechange = function () {
           if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
               var response = xhr.responseText;
               current_weather_conditions.temp = response
           }
       }
            xhr.send(); // begin the request
   }

        function readDescFile(fileUrl){     // read current weather conditions from text file
            var xhr = new XMLHttpRequest;
            xhr.open("GET", fileUrl); // set Method and File
            xhr.onreadystatechange = function () {
            if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
               var response = xhr.responseText;
               current_weather_conditions.desc = response
           }
       }
            xhr.send(); // begin the request
   }
    
    Text {
        id:time
        anchors.top:root.top
        bottomPadding:-20
        leftPadding:-10
        text: Qt.formatTime(timeSource.data["Local"]["DateTime"],"h:mm ap").replace("am", "").replace("pm", "")
        color: font_color
        renderType: Text.QtRendering
        font {
            pointSize: 84
            family: font_style1
        }
    }
    Text {
        id:date
        topPadding:20
        bottomPadding:10
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
            family: font_style1
        }
    }
    

     Image {
       id: wIcon
       property var wIconurl:readIconFile("/home/hammer/.local/share/plasma/look-and-feel/DigiTech/contents/code/icon.txt")
       anchors.top:date.bottom
       horizontalAlignment: Image.AlignLeft
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
        property var temp:readTempFile("/home/hammer/.local/share/plasma/look-and-feel/DigiTech/contents/code/temp.txt")
        property var desc:readDescFile("/home/hammer/.local/share/plasma/look-and-feel/DigiTech/contents/code/desc.txt")
        text:"         "+temp+desc
        font.family: font_style2
        font.pointSize: 24
        font.capitalization: Font.Capitalize
        color: font_color
        // color: ColorScope.textColor
        antialiasing : true
        }
        
        Timer {                  // timer to trigger update for weather temperature
        id: readTemp
        interval: 31 * 60 * 1000 // every 30 minutes
        running: true
        repeat:  true
        onTriggered: read_txt.readTempFile("/home/hammer/.local/share/plasma/look-and-feel/DigiTech/contents/code/temp.txt");
        }
        Timer{
        id: readDesc             // timer to trigger update for weather conditions
        interval: 31 * 60 * 1000   // every 30 minutes
        running: true
        repeat:  true
        onTriggered: read_txt.readDescFile("/home/hammer/.local/share/plasma/look-and-feel/DigiTech/contents/code/desc.txt");
        }
        Timer{
        id: readIcon             // timer to trigger update for weather condition icon
        interval: 31 * 60 * 1000  // every 30 minutes
        running: true
        repeat:  true
        onTriggered: wIcon.readIconFile("/home/hammer/.local/share/plasma/look-and-feel/DigiTech/contents/code/icon.txt");
        }
        
    Image {
        id:email_icon
        anchors.top:wIcon.bottom
        x:10
        source: "/home/hammer/.local/share/plasma/look-and-feel/DigiTech/contents/icons/email3.png"
        smooth: true
        sourceSize.width: 48
        sourceSize.height: 48
        }
      
      Text {
        id:email_count
        anchors.top:wIcon.bottom
        topPadding:5
        text: "          "+Gmail.count
        font.family: font_style2
        font.bold:true
        font.pointSize:20
       // color: ColorScope.textColor
        color: font_color
        antialiasing : true
    }
   
    DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }
}
