# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'

FILE = 'output.json'

def memo_data
  if File.read(FILE).empty?
    initial_memo_data = { "memos": [] }
    File.open(FILE, 'w') { |f| f.puts(initial_memo_data.to_json) }
  end
  JSON.parse(File.read(FILE))
end

helpers do
  def h(text)
    ERB::Util.html_escape(text)
  end
end

get '/' do
  @memo_list = memo_data
  erb :top
end

get '/memos/:id' do
  @id = params['id'].to_i
  @memo_list = memo_data
  erb :show
end

get '/new' do
  erb :new
end

post '/memos' do
  memo_list = memo_data
  File.open(FILE, 'w') do |f|
    count = memo_list['memos'].empty? ? 1 : memo_list['memos'].last['id'].to_i + 1
    memo_list['memos'] << { id: count, title: h(params[:title]), content: h(params[:content]) }
    f.puts(memo_list.to_json)
  end
  redirect '/'
end

get '/memos/:id/edit' do
  @id = params['id'].to_i
  @memo_list = memo_data
  erb :edit
end

patch '/memos/:id' do
  @id = params['id'].to_i
  memo_list = memo_data
  memo = memo_list['memos'].find { |hash| hash['id'] == @id }

  memo['title'] = h(params[:title])
  memo['content'] = h(params['content'])

  File.open(FILE, 'w') do |f|
    f.puts(memo_list.to_json)
  end
  redirect '/'
end

delete '/memos/:id' do
  @id = params['id'].to_i
  memo_list = memo_data
  memo_list['memos'].delete_if { |memo| memo['id'] == @id }

  File.open(FILE, 'w') do |f|
    f.puts(memo_list.to_json)
  end

  redirect '/'
end

not_found do
  '指定したページは存在しません'
end
