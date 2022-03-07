# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'

file = 'output.json'
data = JSON.parse(File.read(file))

get '/' do
  @data = data
  erb :top
end

get '/memos/:id' do
  @id = params['id'].to_i
  @data = data
  erb :show
end

get '/new' do
  erb :new
end

post '/create' do
  File.open(file, 'w') do |f|
    count = data['memos'].last['id'] + 1
    data['memos'] << { 'id' => count, 'title' => params[:title], 'content' => params[:content] }
    f.puts(data.to_json)
  end
  redirect '/'
end

get '/memos/:id/edit' do
  @id = params['id'].to_i
  @data = data
  erb :edit
end

patch '/memos/:id/update' do
  @id = params['id'].to_i
  data['memos'].each do |memo|
    next if memo['id'] != @id

    memo['title'] = params[:title]
    memo['content'] = params['content']
  end

  File.open(file, 'w') do |f|
    f.puts(data.to_json)
  end
  redirect '/'
end

delete '/memos/:id/delete' do
  @id = params['id'].to_i
  data['memos'].each do |memo|
    next if memo['id'] != @id

    data['memos'].delete(memo)
  end

  File.open(file, 'w') do |f|
    f.puts(data.to_json)
  end

  redirect '/'
end
