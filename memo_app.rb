# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'pg'

DB_NAME = ENV['DB_NAME']
TABLE_NAME = ENV['TABLE_NAME']

def client
  PG.connect(
    host: ENV['DB_HOST'],
    user: ENV['DB_USER'],
    password: ENV['DB_PASSWORD'],
    dbname: DB_NAME,
    port: ENV['DB_PORT']
  )
end

CONNECTION = client

helpers do
  def h(text)
    ERB::Util.html_escape(text)
  end
end

get '/' do
  sql = "SELECT * FROM #{TABLE_NAME}"
  @memos = CONNECTION.exec_params(sql)
  erb :top
end

get '/memos/:id' do
  id = params['id']
  sql = "SELECT * FROM #{TABLE_NAME} WHERE id = $1"
  @memo = CONNECTION.exec_params(sql, [id])
  erb :show
end

get '/new' do
  erb :new
end

post '/memos' do
  index = 0
  sql = "SELECT MAX(id) FROM #{TABLE_NAME}"
  last_id = CONNECTION.exec_params(sql)
  last_id.each do |id|
    index = id['max'].nil? ? 1 : id['max'].to_i + 1
  end

  title = params[:title]
  content = params[:content]
  format_values = format("%<index>i, '%<title>s', '%<content>s'", index: index, title: title, content: content)

  sql = "INSERT INTO #{TABLE_NAME} (id, title, content) VALUES (#{format_values})"
  CONNECTION.exec_params(sql)

  redirect '/'
end

get '/memos/:id/edit' do
  id = params['id']
  sql = "SELECT * FROM #{TABLE_NAME} WHERE id = $1"
  @memo = CONNECTION.exec_params(sql, [id])
  erb :edit
end

patch '/memos/:id' do
  id = params['id']
  title = params[:title]
  content = params[:content]
  format_values = format("'%<title>s', '%<content>s'", title: title, content: content)
  sql = "UPDATE #{TABLE_NAME} SET (title, content) = (#{format_values}) WHERE id = $1"
  CONNECTION.exec_params(sql, [id])

  redirect '/'
end

delete '/memos/:id' do
  id = params['id']
  sql = "DELETE FROM #{TABLE_NAME} WHERE id = $1"
  CONNECTION.exec_params(sql, [id])
  redirect '/'
end

not_found do
  '指定したページは存在しません'
end
