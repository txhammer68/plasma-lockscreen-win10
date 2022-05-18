
// custom clock for plasma lockscreen ala windows 10 style
// shows time,weather,events, in lower left corner
// /usr/lib/x86_64-linux-gnu/libexec/kscreenlocker_greet --testing --theme $HOME/.local/share/plasma/look-and-feel/MyBreeze

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.1
import org.kde.plasma.core 2.0
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM

Item {
    id:root
    property var font_color:"white"
    property var font_style1:"Michroma"   // install Michroma font
    property var font_style2:"Noto Sans"
    property var url1:"https://api.openweathermap.org/data/2.5/onecall?"+geoLocation+"&units=imperial&appid=5819a34c58f8f07bc282820ca08948f1"
    property var geoLocation:"lat="+geoCode.data["location"]["latitude"]+"&lon="+geoCode.data["location"]["longitude"]
    property var weather:{}
    property var warnings:weather.hasOwnProperty("alerts") ? true:false // check if alert exists
    property var conditions:Math.round(weather.current.temp)+"° "+weather.current.weather[0].main+"<br><&nbsp;> "+Math.round(weather.daily[0].temp.min)+"° | "+Math.round(weather.daily[0].temp.max)+"°"
    property var alert_text: warnings ? Math.round(weather.current.temp)+"° "+weather.current.weather[0].main+"<br><&nbsp;> "+"⚠️ "+weather.alerts[0].title : "None"
    property int today:Qt.formatDate(timeSource.data["Local"]["DateTime"],"MMdd")
    property var nth:getOrdinal(Qt.formatDate(timeSource.data["Local"]["DateTime"],"d"))

    property var h:info.height
    property var events:{          /// need to update yearly for mardi gras,easter,mothersa day,fathers day,memorial day,Thanksgiving
        0101:"🎊 New Year's Day",
        0202:"🦫 Groundhog Day",
        0211:"🎂 Dad's Birthday",
        0214:"💘 Valentine's Day",
        0221:"🇺🇸 Presidents' Day",
        0301:"🎉 Mardi Gras!",
        0317:"🍀 St. Patricks day",
        0401:"April Fools' Day",
        0417:"Easter",
        0422:"♻ Earth Day",
        0504:"🔫 May the Force be With You",
        0505:"🇲🇽 Cinco De Mayo",
        0530:"🇺🇸 Memorial Day",
        0614:"🇺🇸 Flag Day",
        0619:"🍺 Father's Day",
        0704:"🇺🇸 Independence Day",
        0905:"🇺🇸 Labor Day",
        0911:"🇺🇸 September 11th (Patriot Day)",
        1031:"🎃 Halloween",
        1124:"🦃 Thanksgiving Day",
        1224:"🎅🏻 Christmas Eve",
        1225:"🎄 Christmas Day",
        1231:"🎊 New Years Eve"
    }

    function getWeather(url){  // get weather info
        var xhr = new XMLHttpRequest;
        xhr.open("GET", url); // set Method and url
        xhr.onreadystatechange = function () {
            if(xhr.readyState === XMLHttpRequest.DONE){ // if request_status == DONE
                var response = xhr.responseText;
                weather=JSON.parse(response)
            }
        }
        xhr.send(); // begin the request
    }

    function getOrdinal(n) {            // assigns superfix to date
        var s=["th","st","nd","rd"],
        v=n%100;
        return (s[(v-20)%10]||s[v]||s[0]);
    }

    Column {
        id:info
        spacing:2
        anchors.top:root.top
        anchors.topMargin:-5

        Text {
            id:time
            bottomPadding:1
            leftPadding:-10
            text: Qt.formatTime(timeSource.data["Local"]["DateTime"],"h:mm ap").replace("am", "").replace("pm", "")
            color: font_color
            font.pointSize: 56
            font.family: font_style1
            antialiasing:true
            style: Text.Outline;
            styleColor: "gray"
        }
        Text {
            id:date
            topPadding:-10
            bottomPadding:2
            textFormat: Text.RichText
            text: Qt.formatDate(timeSource.data["Local"]["DateTime"],"dddd, MMMM  d") +"<sup>"+nth+"</sup>"
            color:font_color
            font.pointSize: 20
            font.family: font_style2
            antialiasing:true
            style: Text.Outline;
            styleColor: "gray"
        }


        Text {
            id:ev
            text:weather.current.weather[0].icon //events[today]
            color:font_color
            antialiasing : true
            font.pointSize: 16
            font.family: font_style2
            font.italic:true
            style: Text.Outline;
            styleColor: "gray"
            visible: events[today] === undefined ? false : true
            height: ev.visible ? date.height*.9 : 0  // hide events if blank
        }

        Row {
            spacing:10
            topPadding:5

            Image {
                id: wIcon
                cache: false
                source:"/icons/"+weather.current.weather[0].icon+".png"
                smooth: true
                verticalAlignment : Image.AlignVBottom
                sourceSize.width: 56
                sourceSize.height: 56
            }

            Text {
                id:current_weather_conditions
                topPadding:-5
                bottomPadding:10
                leftPadding:20
                textFormat: Text.RichText
                text:warnings ? alert_text : conditions
                font.family: font_style2
                font.pointSize: 16
                font.capitalization: Font.Capitalize
                color:font_color
                antialiasing : true
                style: Text.Outline;
                styleColor: "gray"
            }
        }
    }
    Timer {                  // timer to trigger update for weather temperature
        id: timerTemp
        interval: 20 * 60 * 1000 // every 20 minutes
        running: true
        repeat:  true
        triggeredOnStart:true
        onTriggered: {
            getWeather(url1)
        }
    }


    Timer {                  // timer to trigger update for weather temperature
        id: waketimerTemp        // remembers timer after resume from suspend mode so it varies when it will update after wake up
        interval: 5000 // every 5 secs
        running: true
        repeat:  false
        onTriggered: {
            getWeather(url1)
        }
    }

 PlasmaNM.NetworkStatus {   // check if network changed for resume from sleep mode...
        id: networkStatus
        onNetworkStatusChanged: {
            if (networkStatus.networkStatus === i18nd(
                        "plasma_applet_org.kde.plasma.networkmanagement",
                        "Connected")) {
                waketimerTemp.restart()

            }
        }
    }

    DataSource {
        id: timeSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 1000
    }

    DataSource {
            id: geoCode
            engine: "geolocation"
            connectedSources: ["location"]
            interval: 100
            onNewData: {   // get weather after geocode update
                //t1.start
                getWeather(url1)
            }
        }
}
