require 'sinatra'

require 'json'
require './function.rb'

get '/rakutan/:kid' do |kid|
  res = get_lecture_by_id(kid)
  if res.result == "success" then
    res.rakutan.to_dict.to_json
  else
    res.result
  end
end

get '/rakutan/search/:word' do |word|
  search_word = word.strip.sub('％', '%')
  res = get_lecture_by_search_word(search_word)
  if res.result == "success" then
    tmp = res.rakutan_list.map{|r| r.to_dict}
    {"searchResult" => tmp, "searchCount" => res.count}.to_json
  else
    res.result
  end
end

get '/users/fav/:uid' do
  res = get_user_favorite(uid)
  if res.result == "success" then
    tmp = res.fav_list.map{|f| f.to_dict}
    {"favList": tmp, "favCount": res.count}.to_json
  else
    res.result
  end
end

post '/users/fav' do
  request.body.rewind
  req = JSON.parse request.body.read
  uid = req['uid']
  lec_id = req['lecID']
  lecture_name = req['lectureName']

  # res = add_user_favorite() TODO:
end

delete '/users/fav/:uid' do
  uid
end

post '/kakomon' do
  {}.to_json
end

delete '/kakomon/:kid' do
  kid
end
