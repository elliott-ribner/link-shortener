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
get "/" do
  erb :create_link
end

#redirect to create link, this time create link is populated with short url variable
#short url variable is from long url
post "/create" do
  long_url = params[:long_url_name]
  short_url_partial = shorten_link ( long_url )
  short_url = "http://localhost:4567/sl/" << short_url_partial
  erb :create_link , locals: { short_url: short_url }
end


def shorten_link long_url
  db_connection do |conn|
    row_count_initial = conn.exec_params("SELECT COUNT (*) FROM list_table;")
    row_count = row_count_initial[0]["count"]
    conn.exec_params("INSERT INTO list_table (id, url) VALUES ($1, $2)", [ row_count , long_url ])
    row_count
    #need to pass row count and long url here
  end
end

#this peice is for turning long url into short url
get "/sl/:short_link_input" do
  short_url = params[:short_link_input]
  long_url = extend_link ( short_url )
  redirect "http://www.google.com" #this will be rediret to long url
end

def extend_link short_url
  db_connection do |conn|
    list_value = conn.exec_params("SELECT url FROM list_table WHERE id = ($1);", [short_url])
    binding.pry
  end
  binding.pry
end
