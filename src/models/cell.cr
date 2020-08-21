class CellValue
  def self.from_json(json)
    new(JSON.parse(json))
  end

  property raw : JSON::Any

  def initialize(@raw)
  end

  def [](field_name)
    raw[field_name]
  end
end

class Cell < Granite::Base
  connection postgres

  table cells

  belongs_to record : Record

  column id : Int64, primary: true
  column name : String
  column data : String?
  column value : CellValue, converter: Granite::Converters::Json(CellValue, JSON::Any)
end