# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'erb'
require 'json'
require 'fileutils'

helpers do
  def h(text)
    ERB::Util.html_escape(text)
  end
end

MEMO_RECORDS_FILE = 'memos.json'

get '/memos' do
  @memos = load_memos
  erb :index
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  memos = load_memos
  id = nil
  title = params[:title]
  content = params[:content]

  new_memo = create_or_update_memo(memos, id, title, content)

  memos << new_memo

  save_memos(memos)
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
  id = params[:id].to_i
  title = params[:title]
  content = params[:content]

  update_memo = create_or_update_memo(memos, id, title, content)

  update_memo[:title] = title
  update_memo[:content] = content

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

def save_memos(memos)
  json_memos = JSON.generate(memos)
  File.write(MEMO_RECORDS_FILE, json_memos)
end

def find_memo(id)
  load_memos.find { |memo| memo[:id] == id.to_i }
end

def create_or_update_memo(memos, id, title, content)
  if id
    memos.find { |memo| memo[:id] == id }
  else
    if memos.empty?
      new_memo = { id: 1, title:, content: }
    else
      max_id = memos.map { |memo| memo[:id] }.max
      new_memo = { id: max_id + 1, title:, content: }
    end
    new_memo
  end
end
