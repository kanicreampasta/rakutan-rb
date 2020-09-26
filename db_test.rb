require './db.rb'

r = Database.use_db do |db|
  db.find("rakutan2020", {id: 10001}, nil)
end
puts r
r.query_result.each {|res| puts res}
