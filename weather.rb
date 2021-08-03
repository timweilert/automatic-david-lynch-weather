#Welcome to the daily weather report, enjoy those blue skies and golden sunshine. Have a great day!
#requires
require 'json'
require 'net/http'
require 'uri'
load 'keys.rb' 
#place a file called keys.rb in the same directory and have the following lines:
# $key = 'your weatherapi.com key'
# $location = 'your zipcode, or city, see https://www.weatherapi.com/docs/ under Request Parameters'

#might need to do pulseaudio --start before running this script

def random_file_getter (directory)
	base_dir = Dir.pwd
	absolute_dir = "#{base_dir}/#{directory}"
	command = "ls -d #{absolute_dir}/* | egrep '\.mp3' | shuf -n 1"
	file = %x[ #{command} ]
end #random_file_getter	

def weather_condition_getter (condition_code)
	case condition_code
	
		when 1000
			condition = "clear"
		when 1006
			condition = "cloudy"
		when 1030, 1135, 1147
			condition = "fog"
		when 1009
			condition = "overcast"
		when 1003
			condition = "partlycloudy"
		when 1171, 1192, 1195, 1243, 1246
			condition = "rain-heavy"
		when 1150, 1153, 1183, 1198, 1240, 1249, 1273
			condition = "rain-light"
		when 1186, 1189, 1201, 1207, 1252, 1276
			condition = "rain-medium"	
		when 1180, 1063, 1069, 1072, 1087
			condition = "rain-possible"
		when 1237
			condition = "ice"
		when 1168, 1114, 1216, 1219
			condition = "snow"
		when 1117, 1222, 1225, 1258, 1264, 1282
			condition = "snow-heavy"
		when 1204, 1210, 1213, 1255, 1261, 1279
			condition = "snow-light"
		when 1066
			condition = "snow-possible"
	end #case	
	return random_file_getter ("audio/06_weather_conditions/#{condition}")
end #condition_getter

def wind_condition_getter(windspeed)
#inspired by the Beaufort Scale https://en.wikipedia.org/wiki/Beaufort_scale
	windspeed = windspeed.round
	case windspeed
		when 0..3
			wind_condition = "still"
		when 4..12
			wind_condition = "weak"
		when 13..24
			wind_condition = "medium"
		else
			wind_condition = "strong"
	end #case
	return random_file_getter ("audio/07_wind_conditions/#{wind_condition}")
end	

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

#current conditions for weather and wind
current_condition_hash = currentdata.fetch("condition")
current_condition_code = current_condition_hash.fetch("code").to_i
current_windspeed = currentdata.fetch("wind_mph").to_f

#Time specific values
day = time_object.day
hour = time_object.hour
minute = time_object.min
month = time_object.month
year = time_object.year
day_of_week = time_object.strftime("%A").downcase

current_time_of_day = 'morning' if hour > 4 && hour < 12
current_time_of_day = 'afternoon' if hour >= 12 && hour < 5
current_time_of_day = 'night' if hour >=5 || hour <= 4

#Swirl the numbers
puts "The current temperature is #{tempf}"
puts "The current time is #{Time.at(time)}"
puts "The current day is #{day}"
puts "It is the month of #{month}"
puts "It is #{minute} minutes"
puts "It is the year #{year}"
puts "it is #{hour}"

items_to_play = []

#good morning, afternoon, or evening
if current_time_of_day == 'morning'
	items_to_play << random_file_getter('audio/01_greeting/morning')
elsif current_time_of_day == 'afternoon'
	items_to_play << random_file_getter('audio/01_greeting/afternoon')
else
	items_to_play << random_file_getter('audio/01_greeting/evening')
end #if
	
#it's [date], [year]

items_to_play << "#{Dir.pwd}/audio/02_date/#{month}#{day}.mp3\n"

items_to_play << random_file_getter("audio/03_year/#{year}")	

items_to_play << random_file_getter("audio/04_day_of_week/#{day_of_week}")

#here in [location], set up for zip code
items_to_play << random_file_getter("audio/05_here_in")

i=0
for i in 0..4
items_to_play << random_file_getter("audio/numbers/#{$location[i,1]}")
i+=1
end #for

# weather conditions
items_to_play << weather_condition_getter(current_condition_code)

#wind conditions
items_to_play << wind_condition_getter(current_windspeed)

File.new("weather.m3u", "w+")

puts items_to_play

items_to_play.each do |item|
	File.open("weather.m3u", "a") {|f| f.write(item)}
end #do	
	puts items_to_play	
	
command = "#{Dir.pwd}/weather.m3u"
exec "mplayer -playlist weather.m3u"