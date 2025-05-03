# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'fileutils'
require 'pg'

DB = PG.connect(dbname: 'memo_app_db')

helpers do
  def h(text)
    ERB::Util.html_escape(text)
  end
end

MEMO_RECORDS_FILE = 'memos.json'

get '/memos' do
  @memos = DB.exec("SELECT * FROM memos ORDER BY id").map do |row|
    { id: row['id'].to_i, title: row['title'], content: row['content'] }
  end
  erb :index
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  DB.exec_params(
    "INSERT INTO memos (title, content) VALUES ($1, $2)",
    [params[:title], params[:content]]
  )
  redirect '/memos'
end

get '/memos/:id' do
  @memo = find_memo(params[:id])
  if @memo
    erb :show
  else
    status 404
    '404 Not Found'
  end
end

get '/memos/:id/editing' do
  @memo = find_memo(params[:id])
  erb :edit
end

patch '/memos/:id' do
  memos = load_memos
  memo = memos.find { |memo| memo[:id] == params[:id].to_i }
  new_memo = memo_params(params)

  memo.merge!(new_memo)

  save_memos(memos)
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  memos = load_memos
  memos.reject! { |memo| memo[:id] == params[:id].to_i }
  save_memos(memos)
  redirect '/memos'
end

not_found do
  status 404
  '404 Not Found'
end

def load_memos
  if File.exist?(MEMO_RECORDS_FILE)
    if File.empty?(MEMO_RECORDS_FILE)
      []
    else
      JSON.parse(File.read(MEMO_RECORDS_FILE), symbolize_names: true)
    end
  else
    []
  end
end

def memo_params(params)
  {
    title: params[:title],
    content: params[:content]
  }
end

def save_memos(memos)
  json_memos = JSON.generate(memos)
  File.write(MEMO_RECORDS_FILE, json_memos)
end
