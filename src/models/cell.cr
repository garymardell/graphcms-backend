class Cell < Granite::Base
  connection postgres

  table cells

  belongs_to record : Record

  column id : Int64, primary: true
  column name : String
  column data : String?
end