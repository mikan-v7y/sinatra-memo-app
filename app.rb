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

class SomeClass
  include ERB::Util
end

SAVE_FILE = 'save_file.json'

def load_memos
  if File.empty?(SAVE_FILE)
    []
  else
    JSON.parse(File.read(SAVE_FILE), symbolize_names: true)
  end
end

def save_memos(memos)
  json_memos = JSON.generate(memos)
  File.write(SAVE_FILE, json_memos)
end

get '/memos' do
  @memos = load_memos
  erb :index
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  title = params[:title]
  content = params[:content]
  memos = load_memos

  if memos.empty?
    new_memo = { id: 1, title: title, content: content }
  else
    max_id = memos.map { |memo| memo[:id] }.max
    new_memo = { id: max_id + 1, title: title, content: content }
  end

  memos << new_memo
  save_memos(memos)
  redirect '/memos'
end

def find_memo(id)
  load_memos.find { |memo| memo[:id] == id.to_i }
end

get '/memos/:id' do
  @memo = find_memo(params[:id])
  if @memo
    erb :show
  else
    '404 Not Found'
  end
end

get '/memos/:id/editing' do
  @memo = find_memo(params[:id])
  erb :edit
end

patch '/memos/:id/editing' do
  memos = load_memos
  memo = memos.find { |memo| memo[:id] == params[:id].to_i }

  memo[:title], memo[:content] = params[:title], params[:content]

  save_memos(memos)
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id/deletion' do
  memos = load_memos
  memos.reject! { |memo| memo[:id] == params[:id].to_i }
  save_memos(memos)
  redirect '/memos'
end

not_found do
  '404 Not Found'
end
