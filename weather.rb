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

current_time_of_day = 'morning' if hour > 4 && hour < 12
current_time_of_day = 'afternoon' if hour >= 12 && hour < 5
current_time_of_day = 'night' if hour >=5 || hour <= 4

#Swirl the numbers
puts "The current temperature is #{tempf}"
puts "The current time is #{Time.at(time)}"
puts "The current day is #{day}"
puts "Is it Friday? #{friday}"
puts "It is the month of #{month}"
puts "It is #{minute} minutes"
puts "It is the year #{year}"
puts "it is #{hour}"

items_to_play = []

#good morning, afternoon, or evening
if current_time_of_day == 'morning'
	items_to_play << random_file_getter('audio/conversation/goodmorning')
elsif current_time_of_day == 'afternoon'
	items_to_play << random_file_getter('audio/conversation/thisafternoon')
else
	items_to_play << random_file_getter('audio/conversation/night')
end #if
	
#it's [date], [year]

items_to_play << "#{Dir.pwd}/audio/dates/#{month}#{day}.mp3\n"

items_to_play << random_file_getter("audio/year/#{year}")	

#here in [location], set up for zip code
items_to_play << random_file_getter("audio/conversation/in")

i=0
for i in 0..4
items_to_play << random_file_getter("audio/numbers/#{$location[i,1]}")
i+=1
end #for

File.new("weather.m3u", "w+")

puts items_to_play

items_to_play.each do |item|
	File.open("weather.m3u", "a") {|f| f.write(item)}
end #do	
	puts items_to_play	
	
command = "#{Dir.pwd}/weather.m3u"
exec "mplayer -playlist weather.m3u"