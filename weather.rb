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
current_weather_source = "http://api.weatherapi.com/v1/forecast.json?key=#{$key}&q=#{$location}&days=2&aqi=no&alerts=no"

#Get current weather data in JSON and turn in to a Ruby hash
resp = Net::HTTP.get_response(URI.parse(current_weather_source))
data = resp.body
current_weather_source = JSON.parse(data)

#Parse the hashes
locationdata = current_weather_source.fetch("location")
currentdata =  current_weather_source.fetch("current")

#Time specific values
time = locationdata.fetch("localtime_epoch")
time_object = Time.at(time)

day = time_object.day
hour = time_object.hour
minute = time_object.min
month = time_object.month
year = time_object.year
day_of_week = time_object.strftime("%A").downcase

current_time_of_day = 'morning' if hour > 4 && hour < 12
current_time_of_day = 'afternoon' if hour >= 12 && hour < 5
current_time_of_day = 'night' if hour >=5 || hour <= 4




forecastdata = current_weather_source.fetch("forecast")
forecast_day = forecastdata.fetch("forecastday")


if current_time_of_day == 'morning' || current_time_of_day == 'afternoon'
	forecast_values = forecast_day[0].fetch("day")
else current_time_of_day == 'night'
	forecast_values = forecast_day[1].fetch("day")
end #if

forecast_tempf = forecast_values.fetch("maxtemp_f").round
forecast_tempc = forecast_values.fetch("maxtemp_c").round
forecast_weather_condition = forecast_values.fetch("condition")
forecast_weather_condition_code = forecast_weather_condition.fetch("code")


#current temps
current_tempf = currentdata.fetch("temp_f").round
current_tempc = currentdata.fetch("temp_c").round

#current conditions for weather and wind
current_condition_hash = currentdata.fetch("condition")
current_condition_code = current_condition_hash.fetch("code").to_i
current_windspeed = currentdata.fetch("wind_mph").to_f



#create an array to store in the various mp3s that will be played in order
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
items_to_play << random_file_getter("audio/XX_everything_else/numbers/#{$location[i,1]}")
i+=1
end #for

# weather conditions
items_to_play << weather_condition_getter(current_condition_code)

#wind conditions
items_to_play << wind_condition_getter(current_windspeed)

items_to_play << random_file_getter("audio/XX_everything_else/numbers/#{current_tempf}")

items_to_play << random_file_getter("audio/XX_everything_else/degreesf")

items_to_play << random_file_getter("audio/XX_everything_else/numbers/#{current_tempc}")

items_to_play << random_file_getter("audio/XX_everything_else/celsius")

#today I'm thinking about..

items_to_play << random_file_getter("audio/09_im_thinking_about")

#later on

if current_time_of_day == 'morning'
	items_to_play << "#{Dir.pwd}/audio/10_later/thisafternoon.mp3"
elsif current_time_of_day == 'afternoon'
	items_to_play << "#{Dir.pwd}/audio/10_later/tonight.mp3"
else current_time_of_day == 'night'
	items_to_play << "#{Dir.pwd}/audio/10_later/tomorrow.mp3"
end #if

items_to_play << random_file_getter("audio/10_later/itwillbe")

items_to_play << random_file_getter("audio/XX_everything_else/numbers/#{forecast_tempf}")

items_to_play << random_file_getter("audio/XX_everything_else/degreesf")

items_to_play << random_file_getter("audio/XX_everything_else/numbers/#{forecast_tempc}")

items_to_play << random_file_getter("audio/XX_everything_else/celsius")

case forecast_weather_condition_code
	when 1000
		items_to_play << random_file_getter("audio/11_blue_skies_golden_sunshine/blueskiesgoldensunshine")
	when 1006, 1003, 1150, 1153, 1183, 1198, 1240, 1249, 1180, 1063, 1069, 1072, 1216, 1204, 1210, 1213, 1255, 1261, 1279, 1066
		items_to_play << random_file_getter("audio/11_blue_skies_golden_sunshine/blueskieswithclouds")
	else
		items_to_play << random_file_getter("audio/11_blue_skies_golden_sunshine/overcast")
end #case

items_to_play << random_file_getter("audio/12_have_a_great_day")		

#make the playlist from the items_to_play array
File.new("weather.m3u", "w+")

puts items_to_play

items_to_play.each do |item|
	File.open("weather.m3u", "a") {|f| f.write(item)}
end #do	
	puts items_to_play	
	
command = "#{Dir.pwd}/weather.m3u"
exec "mplayer -playlist weather.m3u"

puts current_tempf
puts current_tempc