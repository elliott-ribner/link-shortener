require 'sinatra'
require 'pg'

configure :development do
  set :db_config, { dbname: "list_table" }
end

configure :production do
  uri = URI.parse(ENV["DATABASE_URL"])
  set :db_config, {
    host: uri.host,
    port: uri.port,
    dbname: uri.path.delete('/'),
    user: uri.user,
    password: uri.password
  }
end

def db_connection
  begin
    connection = PG.connect(settings.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get "/" do
  erb :create_link
end
#initial visit to page
get "/create_link" do
  erb :create_link
end

#redirect to create link, this time create link is populated with short url variable
post "/create" do
  long_url = params[:long_url_name]
  short_url_partial = shorten_link ( long_url )
  short_url = "https://tooshrt.herokuapp.com/s/" << short_url_partial
  erb :create_link , locals: { short_url: short_url }
end

def shorten_link long_url
  partial_link_path = ('a'..'z').to_a.concat((0..9).to_a).sample(5).join
  db_connection do |conn|
    conn.exec_params("INSERT INTO list_table (id, url) VALUES ($1, $2)", [ partial_link_path , long_url ])
    partial_link_path
  end
end

#visiting this page redirects to web page
get "/s/:short_link_input" do
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
