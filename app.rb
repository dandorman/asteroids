require 'sinatra'
require 'coffee-script'

get '/' do
  File.read(File.join('public', 'index.html'))
end

get '/app.js' do
  coffee :app
end
