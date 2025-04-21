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
  new_memo = create_new_memo(memos, params)

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
  create_new_memo(memos, params)

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

def create_new_memo(memos, params)
  new_memo = { title: params[:title], content: params[:content] }

  if params[:id] && (memo = memos.find { |m| m[:id] == params[:id].to_i })
    memo.merge!(new_memo)
    memo
  else
    max_id = memos.map { |m| m[:id] }.max || 0
    new_memo[:id] = max_id + 1
    new_memo
  end
end
