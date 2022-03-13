# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'

file = 'output.json'
memo_data = JSON.parse(File.read(file))

get '/' do
  @data = memo_data
  erb :top
end

get '/memos/:id' do
  @id = params['id'].to_i
  @data = memo_data
  erb :show
end

get '/new' do
  erb :new
end

post '/memos' do
  File.open(file, 'w') do |f|
    count = data['memos'].last['id'] + 1
    memo_data['memos'] << { 'id' => count, 'title' => params[:title], 'content' => params[:content] }
    f.puts(data.to_json)
  end
  redirect '/'
end

get '/memos/:id/edit' do
  @id = params['id'].to_i
  @data = memo_data
  erb :edit
end

patch '/memos/:id' do
  @id = params['id'].to_i
  memo = memo_data['memos'].find { |memo| memo['id'] == @id }

  memo['title'] = params[:title]
  memo['content'] = params['content']

  File.open(file, 'w') do |f|
    f.puts(memo_data.to_json)
  end
  redirect '/'
end

delete '/memos/:id' do
  @id = params['id'].to_i
  memo_data['memos'].delete_if { |memo| memo['id'] == @id }

  File.open(file, 'w') do |f|
    f.puts(memo_data.to_json)
  end

  redirect '/'
end

not_found do
  '指定したページは存在しません'
end
