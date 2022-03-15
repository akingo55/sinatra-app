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
  @memos = memo_data
  erb :top
end

get '/memos/:id' do
  @memo = memo_data['memos'].find { |hash| hash['id'] == params['id'].to_i }
  erb :show
end

get '/new' do
  erb :new
end

post '/memos' do
  memos = memo_data
  File.open(FILE, 'w') do |f|
    count = memos['memos'].empty? ? 1 : memos['memos'].last['id'].to_i + 1
    memos['memos'] << { id: count, title: h(params[:title]), content: h(params[:content]) }
    f.puts(memos.to_json)
  end
  redirect '/'
end

get '/memos/:id/edit' do
  @memo = memo_data['memos'].find { |hash| hash['id'] == params['id'].to_i }
  erb :edit
end

patch '/memos/:id' do
  memos = memo_data
  memo = memos['memos'].find { |hash| hash['id'] == params['id'].to_i }

  memo['title'] = h(params[:title])
  memo['content'] = h(params['content'])

  File.open(FILE, 'w') do |f|
    f.puts(memos.to_json)
  end
  redirect '/'
end

delete '/memos/:id' do
  memos = memo_data
  memos['memos'].delete_if { |memo| memo['id'] == params['id'].to_i }

  File.open(FILE, 'w') do |f|
    f.puts(memos.to_json)
  end

  redirect '/'
end

not_found do
  '指定したページは存在しません'
end
