require './db.rb'

db = Database.new
r = db.find("rakutan2020", {id: 10001}, nil)
puts r
r.query_result.each {|res| puts res}
db.close
