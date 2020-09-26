require 'mongo'

class Database
  def initialize
    @client = Mongo::Client.new("mongodb://127.0.0.1:27017/rakutanDB")
  end

  def close
    @client.close
  end

  @@FindResult = Struct.new("FindResult", :result, :count, :query_result)

  def find(col_name, query, projection)
    res = @@FindResult.new
    collection = @client[col_name]
    query_results = collection.find(query)
    count = collection.count_documents(query)
    res.result = :success
    res.count = count
    res.query_result = query_results
    res
  end

  @@UpdateResult = Struct.new("UpdateResult", :result, :count)

  def update(col_name, query)
    res = @@UpdateResult.new
    collection = @client[col_name]
    count = collection.find_one_and_update(query).count
    res.result = if count > 0 then "success" else "fail" end
    res.count = count
    res
  end

  def insert(col_name, document)
    collection = @client[col_name]
    count = collection.insert_one(document)
    :success
  end

  @@DeleteResult = Struct.new("DeleteResult", :result, :count)

  def delete(col_name, query)
    res = @@DeleteResult.new
    collection = @client[col_name]
    count = collection.delete_one(query).deleted_count
    res.result = if count > 0 then "success" else "fail" end
    res.count = count
    res
  end

  def exists?(col_name, query)
    collection = @client[col_name]
    count = collection.count_documents(query)
    count > 0
  end
end
