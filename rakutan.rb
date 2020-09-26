class Rakutan
  def initialize(lecid, fn, ln, g, c, a, t, u)
    @lec_id = lecid
    @faculty_name = fn
    @lecture_name = ln
    @groups = g
    @credits = c
    @accepted = a
    @total = t
    @url = u
  end

  attr_accessor :lec_id, :faculty_name, :lecture_name, :groups, :credits, :accepted, :total, :url

  def self.from_dict(db)
    self.new(db["id"], db["facultyname"], db["lecturename"], db["groups"],
             db["credits"], [db["accept_prev"], db["accept_prev2"], db["accept_prev3"]],
             [db["total_prev"], db["total_prev2"], db["total_prev3"]],
             db["url"])
  end

  def self.from_list(lst)
    lst.map(&self.method(:from_dict))
  end

  def to_dict
    {
      lecID: @lec_id,
      facultyName: @faculty_name,
      lectureName: @lecture_name,
      groups: @groups,
      credits: @credits,
      accepted: @accepted,
      total: @total,
      url: @url
    }
  end
end

class UserFav
  def initialize(uid, lecid, ln)
    @uid = uid
    @lec_id = lecid
    @lecture_name = ln
  end

  def self.from_dict(dic)
    self.new(dic["uid"], dic["lectureid"], dic["lecturename"])
  end

  def self.from_list(lst)
    lst.map(&self.method(:from_dict))
  end

  def to_dict
    {
      uid: @uid,
      lecID: @lec_id,
      lectureName: @lecture_name
    }
  end
end
