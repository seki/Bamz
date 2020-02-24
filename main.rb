require 'webrick'
require 'json'
require_relative 'src/bamz'

port = Integer(ENV['PORT']) rescue 8080
server = WEBrick::HTTPServer.new({:Port => port})

server.mount('/', WEBrick::HTTPServlet::FileHandler, 'index.html')

$bams = Bamz.new
server.mount_proc('/api') do |req, res|
  text =  JSON.parse(req.query['text'])
  res.content_type = "application/json; charset=UTF-8"
  res.body = $bams.search(text).to_json
end

trap(:INT){exit!}
server.start