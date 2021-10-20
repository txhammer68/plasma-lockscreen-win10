#!/bin/bash
curl -s -X GET "https://api.weather.com/v3/wx/observations/current?geocode=22.64%2C-92.02&units=e&language=en-US&format=json&apiKey=api-key" -H  "accept: application/json" -o /tmp/weather.json >/dev/null
curl -s -X GET "https://api.weather.com/v3/wx/forecast/daily/5day?language=en&apiKey=api-key&geocode=22.64,-92.02&units=e&format=json" -H  "accept: application/json" -o /tmp/forecast.json >/dev/null
exit
