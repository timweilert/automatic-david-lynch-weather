# automatic-david-lynch-weather
Your own personal David Lynch Daily Weather Report

To enable a pushbutton (momentary latch switch) upon system boot, add the following line to crontab -e

@reboot sudo python3 /home/pi/automatic-david-lynch-weather/button.py

Furthermore, wire the button between ground and GPIO 26 or adjust button.py to accomodate the GPIO pin of your choice.

This assumes you've installed this repo in the /home/pi directory. 
