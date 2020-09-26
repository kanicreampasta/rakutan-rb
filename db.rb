require 'mongo'

class Database
  def initialize
    @client = Mongo::Client.new(addr)
  end

  def find(col_name, query, projection)

  end

  def update(col_name, query)

  end

  def insert(col_name, document)

  end

  def delete(col_name, query)

  end

  def exists?(col_name, query)

  end
end
