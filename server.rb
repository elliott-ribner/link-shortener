require 'sinatra'
require 'pry'
require 'pg'

def db_connection
  begin
    connection = PG.connect(dbname: "url_list")
    yield(connection)
  ensure
    connection.close
  end
end

#initial visit to page
get "/create_link" do
  erb :create_link
end

#redirect to create link, this time create link is populated with short url variable
post "/create" do
  long_url = params[:long_url_name]
  short_url_partial = shorten_link ( long_url )
  short_url = "http://localhost:4567/sl/" << short_url_partial
  erb :create_link , locals: { short_url: short_url }
end

def shorten_link long_url
  partial_link_path = ('a'..'z').to_a.concat((0..9).to_a).sample(8).join
  db_connection do |conn|
    conn.exec_params("INSERT INTO list_table (id, url) VALUES ($1, $2)", [ partial_link_path , long_url ])
    #need to pass row count and long url here
    partial_link_path
  end
end

#visiting this page redirects to web page
get "/sl/:short_link_input" do
  short_url = params[:short_link_input]
  long_url = extend_link ( short_url )
  redirect "http://#{long_url}"
end

def extend_link short_url
  db_connection do |conn|
    list_value = conn.exec_params("SELECT url FROM list_table WHERE id = ($1);", [short_url])
    list_value[0]["url"]
  end
end
