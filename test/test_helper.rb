$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require 'irb'
require "ulid/rails"

require "minitest/autorun"

db_sets = {
  "sqlite3" => {
    adapter: 'sqlite3',
    database: ':memory:'
  },
  "mysql56" => {
    host: 'mysql56',
    adapter: 'mysql2',
    username: 'root',
    password: 'password',
    database: 'test',
    encoding: 'utf8mb4',
    charset: 'utf8mb4'
  },
  "mysql57" => {
    host: 'mysql57',
    adapter: 'mysql2',
    username: 'root',
    password: 'password',
    database: 'test'
  },
  "mysql80" => {
    host: 'mysql80',
    adapter: 'mysql2',
    username: 'root',
    password: 'password',
    database: 'test'
  },
  "pg12" => {
    host: 'pg12',
    adapter: 'postgresql',
    username: 'postgres',
    database: 'test'
  },
}
db = db_sets[ENV["DB"]] || db_sets['sqlite3']

unless db[:adapter] == 'sqlite3'
  ActiveRecord::Base.establish_connection(db.except(:database))
  ActiveRecord::Base.connection.drop_database(db[:database]) rescue nil

  ActiveRecord::Base.connection.create_database(db[:database], charset: db[:charset])
end

ActiveRecord::Base.establish_connection(db)

ActiveRecord::Schema.define do
  self.verbose = false

  create_table(:users, id: false) do |t|
    t.binary :id, limit: 16, primary_key: true
  end

  create_table(:books, id: false) do |t|
    t.binary :id, limit: 16, primary_key: true
    t.binary :user_id, limit: 16
  end

  create_table(:user_articles, id: false) do |t|
    t.binary :id, limit: 16, primary_key: true
    t.binary :user_id, limit: 16
    t.binary :article_id, limit: 16
  end

  create_table(:articles, id: false) do |t|
    t.binary :id, limit: 16, primary_key: true
  end

  create_table(:widgets) do |t|
    t.binary :ulid, limit: 16
  end
end

class User < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true

  has_many :books
  has_many :user_articles
  has_many :articles, through: :user_articles
end

class Book < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true
  ulid :user_id

  belongs_to :user
end

class UserArticle < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true
  ulid :user_id
  ulid :article_id

  belongs_to :user
  belongs_to :article
end

class Article < ActiveRecord::Base
  include ULID::Rails
  ulid :id, primary_key: true
end

class WidgetWithAutoGeneratedUlid < ActiveRecord::Base
  self.table_name = "widgets"

  include ULID::Rails
  ulid :ulid, auto_generate: true
end
