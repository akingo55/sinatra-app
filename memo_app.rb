# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'pg'

FILE = 'output.json'
DB_NAME = ENV['DB_NAME']
TABLE_NAME = ENV['TABLE_NAME']

def db(sql)
  conn = PG.connect(dbname: DB_NAME)
  conn.exec(sql)
end

helpers do
  def h(text)
    ERB::Util.html_escape(text)
  end
end

get '/' do
  sql = "SELECT * FROM #{TABLE_NAME}"
  @memos = db(sql)
  erb :top
end

get '/memos/:id' do
  sql = "SELECT * FROM #{TABLE_NAME} WHERE id = #{params['id']}"
  @memo = db(sql)
  erb :show
end

get '/new' do
  erb :new
end

post '/memos' do
  index = nil
  last_id = db("SELECT id from #{TABLE_NAME} order by id desc limit 1")
  last_id.each do |id|
    index = id['id'].to_i + 1
  end

  title = params[:title]
  content = params[:content]
  format_values = format("%<index>i, '%<title>s', '%<content>s'", index: index, title: title, content: content)

  sql = "INSERT INTO #{TABLE_NAME} (id, title, content) VALUES (#{format_values})"
  db(sql)

  redirect '/'
end

get '/memos/:id/edit' do
  sql = "SELECT * FROM #{TABLE_NAME} WHERE id = #{params['id']}"
  @memo = db(sql)
  erb :edit
end

patch '/memos/:id' do
  id = params['id']
  title = params[:title]
  content = params[:content]
  format_values = format("'%<title>s', '%<content>s'", title: title, content: content)
  sql = "UPDATE #{TABLE_NAME} SET (title, content) = (#{format_values}) WHERE id = #{id}"
  db(sql)

  redirect '/'
end

delete '/memos/:id' do
  sql = "DELETE FROM #{TABLE_NAME} WHERE id = #{params['id']}"
  db(sql)
  redirect '/'
end

not_found do
  '指定したページは存在しません'
end
