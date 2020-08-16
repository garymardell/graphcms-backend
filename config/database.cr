require "pg"
require "granite"
require "granite/adapter/pg"

Granite::Connections << Granite::Adapter::Pg.new(name: "postgres", url: ENV["DATABASE_URL"])