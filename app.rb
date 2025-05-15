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

get '/memos' do
  @memos = DB.exec('SELECT * FROM memos ORDER BY id').map do |row|
    { id: row['id'].to_i, title: row['title'], content: row['content'] }
  end
  erb :index
end

get '/memos/new' do
  erb :new_memo
end

post '/memos' do
  DB.exec_params(
    'INSERT INTO memos (title, content) VALUES ($1, $2)',
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
  DB.exec_params(
    'UPDATE memos SET title = $1, content = $2 WHERE id = $3',
    [params[:title], params[:content], params[:id]]
  )
  redirect "/memos/#{params[:id]}"
end

delete '/memos/:id' do
  DB.exec_params('DELETE FROM memos WHERE id = $1', [params[:id]])
  redirect '/memos'
end

not_found do
  status 404
  '404 Not Found'
end

def find_memo(id)
  result = DB.exec_params('SELECT * FROM memos WHERE id = $1 LIMIT 1', [id])
  return nil if result.ntuples.zero?

  row = result[0]
  { id: row['id'].to_i, title: row['title'], content: row['content'] }
end
