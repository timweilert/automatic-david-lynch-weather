#Welcome to the daily weather report, enjoy those blue skies and golden sunshine. Have a great day!
#requires
require 'json'
require 'net/http'
require 'uri'
load 'keys.rb' 
#place a file called keys.rb in the same directory and have the following lines:
# $key = 'your weatherapi.com key'
# $location = 'your zipcode, or city, see https://www.weatherapi.com/docs/ under Request Parameters'

#API calls for openweathermap.org
current_weather_source = "http://api.weatherapi.com/v1/forecast.json?key=#{$key}&q=#{$location}&days=1&aqi=no&alerts=no"

#Get current weather data in JSON and turn in to a Ruby hash
resp = Net::HTTP.get_response(URI.parse(current_weather_source))
data = resp.body
current_weather_source = JSON.parse(data)

#Parse the hashes
locationdata = current_weather_source.fetch("location")
currentdata =  current_weather_source.fetch("current")
tempf = currentdata.fetch("temp_f")
time = locationdata.fetch("localtime_epoch")
time_object = Time.at(time)


#Time specific values
day = time_object.day
hour = time_object.hour
minute = time_object.min
month = time_object.month
year = time_object.year
friday = time_object.friday?

morning = true if hour > 4 && hour < 12
afternoon = true if hour >= 12 && hour < 5
night = true if hour >=5

#Swirl the numbers
puts "The current temperature is #{tempf}"
puts "The current time is #{Time.at(time)}"
puts "The current day is #{day}"
puts "Is it Friday? #{friday}"
puts "It is the month of #{month}"
puts "It is #{minute} minutes"
puts "It is the year #{year}"

puts current_weather_source

#exec 'omxplayer "/home/pi/8_hours_sleep_sounds.mp3"'
