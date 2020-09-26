require './db.rb'
require './rakutan.rb'

GetRakutanResult = Struct.new(:result, :rakutan)

Response = {
  1001 => ->(kid) {"講義ID「%d」の検索で接続エラーが発生しました" % kid },
  1404 => ->(kid) {"講義ID「%d」は存在しません" % kid},
  2001 => ->(kid) {"「%s」の検索で接続エラーが発生しました" % kid},
  2404 => ->(kid) {"「%s」は見つかりませんでした" % kid},
  3001 => ->(uid) {"ユーザー「%d」のお気に入りの取得で接続エラーが発生しました" % uid},
  3404 => ->(uid) {"ユーザー「%d」のお気に入りはまだありません。" % uid},
  4001 => "{0}おみくじで接続エラーが発生しました",
  4002 => "{0}おみくじは存在しません",
  4404 => "{0}おみくじに該当する講義が見つかりませんでした"
}

def get_lecture_by_id(kid)
  db = Database.new
  dr = db.find("rakutan", {id: kid}, nil)
  res = GetRakutanResult.new
  
  if dr.result == :success then
    if dr.count == 0 then
      res.result = Response[1404].call(kid)
    else
      res.result = "success"
      res.rakutan = Rakutan::from_dict(dr.query_result.each.next)
    end
  else
    res.result = Response[1001].call(kid)
  end

  db.close
  res
end

GetRakutansResult = Struct.new(:result, :count, :rakutan_list)

def get_lecture_by_search_word(search_word)
  db = Database.new

  if search_word[0] == "%" then
    query = {"lecturename": {"$regex": search_word[1..-1], "$options": "i"}}
  else
    query = {"lecturename": {"$regex": "^%s" % search_word, "$options": "i"}}
  end

  dr = db.find("rakutan", query, {_id: false})

  res = GetRakutansResult.new
  if dr.result == :success then
    if dr.count == 0 then
      res.result = Response[2404].call(search_word)
    else
      res.result = "success"
      res.count = dr.count
      res.rakutan_list = Rakutan::from_list(dr.query_result)
    end
  else
    res.result = Response[2001].call(search_word)
  end

  db.close
  res
end

GetUserFavResult = Struct.new(:result, :count, :fav_list)

def get_user_favorite(uid)
  db = Database.new
  query = {uid: uid}
  dr = db.find('userfav', query, nil)

  res = GetUserFavResult.new

  if dr.result == :success then
    if count == 0 then
      res.result = Response[3404].call(uid)
    else
      res.result = "success"
      res.count = dr.count
      res.fav_list = UserFav::from_list(dr.query_result)
    end
  else
    res.result = Response[3001].call(uid)
  end

  dr.close
  res
end

def get_omikuji(omikuji_type)
  db = Database.new
  res = GetRakutanResult.new

  if omikuji_type == :oni then
    query = {'$and': [{'facultyname': '国際高等教育院'}, {'total_prev': {'$gt': 4}},
      {'$expr': {'$lt': ['$accept_prev', {'$multiply': [0.31, '$total_prev']}]}}]}
  elsif omikuji_type == :normal then
    query = {'$and': [{'facultyname': '国際高等教育院'}, {'accept_prev': {'$gt': 15}},
      {'$expr': {'$gt': ['$accept_prev', {'$multiply': [0.8, '$total_prev']}]}}]}
  else
    res.result = Response[4002].call(omikuji_type)
    return res
  end

  dr = db.find("rakutan", query, nil)

  if dr.result == :success then
    if dr.count == 0 then
      res.result = Response[4404].call(omikuji_type)
    else
      res.result = "success"
      res.rakutan = Rakutan::from_list(dr.query_result).sample
    end
  else
    res.result = Response[4001].call(omikuji_type)
  end

  db.close
  res
end
