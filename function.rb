require './db.rb'
require './rakutan.rb'

GetRakutanResult = Struct.new(:result, :rakutan)

Response = {
  1001 => ->(kid) {"講義ID「%d」の検索で接続エラーが発生しました" % kid },
  1404 => ->(kid) {"講義ID「%d」は存在しません" % kid},
  2001 => ->(kid) {"「%s」の検索で接続エラーが発生しました" % kid},
  2404 => ->(kid) {"「%s」は見つかりませんでした" % kid},
  3001 => ->(uid) {"ユーザー「%d」のお気に入りの取得で接続エラーが発生しました" % uid},
  3002 => ->(uid) {"ユーザー「%d」のお気に入りの追加で接続エラーが発生しました" % uid},
  3003 => ->(uid) {"ユーザー「%d」のお気に入りの削除で接続エラーが発生しました" % uid},
  3404 => ->(uid) {"ユーザー「%d」のお気に入りはまだありません。" % uid},
  3405: "すでにお気に入り登録されています",
  3406 => ->(uid, lec_id) {"ユーザー「%d」に講義ID「%d」をお気に入り登録しました" % [uid, lec_id]},
  3407 => ->(uid, lec_id) {"ユーザー「%d」の講義ID「%d」をお気に入り削除しました" % [uid, lec_id]},
  3408 => ->(lec_id) {"講義ID「%d」はお気に入り登録されていません" % lec_id},
  3409 => ->(lec_id) {"講義ID「%d」はすでに削除されているかお気に入り登録されていません" % lec_id},
  4001 => ->(omikuji) {"%sおみくじで接続エラーが発生しました" % omikuji.to_s},
  4002 => ->(omikuji) {"%sおみくじは存在しません" % omikuji.to_s},
  4404 => ->(omikuji) {"%sおみくじに該当する講義が見つかりませんでした" % omikuji.to_s}
  5001: "提供されている過去問リンクの取得で接続エラーが発生しました",
  5002: "過去問リンクの追加で接続エラーが発生しました",
  5003: "不正なURL形式です",
  5004: "提供されている過去問リンクの削除で接続エラーが発生しました",
  5404: "提供されている過去問リンクはありません",
  5405 => ->(lec_id) {"講義ID「%d」の過去問リンクをリストに追加しました" % lec_id},
  5406 => ->(lec_id, link) {"講義ID「%d」の過去問リンク[%s]をリストから削除しました" % [lec_id, link]},
  5407 => ->(lec_id, link) {"講義ID「%d」の過去問リンク[%s]は存在しません" % [lec_id, link]},
  5408 => ->(lec_id, link) {"講義ID「%d」の過去問リンク[%s]は存在しないかすでに削除されています % [lec_id, link]}"
}

def get_lecture_by_id(kid)
  db = Database.new
  dr = db.find("rakutan2020", {lecID: kid.to_i}, nil)
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
    query = {"lectureName": {"$regex": search_word[1..-1], "$options": "i"}}
  else
    query = {"lectureName": {"$regex": "^%s" % search_word, "$options": "i"}}
  end

  dr = db.find("rakutan2020", query, {_id: false})

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

def add_user_favorite(uid, lec_id)

end

def get_omikuji(omikuji_type)
  db = Database.new
  res = GetRakutanResult.new

  if omikuji_type == :oni then
    query = {'$and': [{'facultyName': '国際高等教育院'}, {'total.0': {'$gt': 4}},
      {'$expr': {'$lt': [{'$arrayElemAt': ['$accepted', 0]}, {'$multiply': [0.31, {'$arrayElemAt': ['$total', 0]}]}]}}]}
  elsif omikuji_type == :normal then
    query = {'$and': [{'facultyName': '国際高等教育院'}, {'accepted.0': {'$gt': 15}},
      {'$expr': {'$gt': [{'$arrayElemAt': ['$accepted', 0]}, {'$multiply': [0.8, {'$arrayElemAt': ['$total', 0]}]}]}}]}
  else
    res.result = Response[4002].call(omikuji_type)
    return res
  end

  dr = db.find("rakutan2020", query, nil)

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

def add_kakomon_url(uid, lec_id, url)

end

def delete_kakomon_url(lec_id, url)

end

def add_users(uid)

end

def update_users(uid)

end
