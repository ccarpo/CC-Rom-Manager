# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20161024085300) do

  create_table "genres", force: :cascade do |t|
    t.string   "name"
    t.integer  "rom_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "genres", ["rom_id"], name: "index_genres_on_rom_id"

  create_table "import_games", force: :cascade do |t|
    t.string   "status"
    t.string   "gameId"
    t.integer  "importStatusId"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "import_statuses", force: :cascade do |t|
    t.datetime "starttime"
    t.datetime "endtime"
    t.integer  "deleteCount"
    t.integer  "scrapeCount"
    t.string   "status"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "console"
    t.integer  "totalCount"
    t.integer  "ignoreCount"
    t.string   "name"
    t.integer  "asyncCount"
  end

  create_table "roms", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.string   "publisher"
    t.integer  "rating"
    t.integer  "players"
    t.date     "releasedate"
    t.string   "developer"
    t.binary   "frontcover"
    t.binary   "backcover"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.string   "frontcover_file_name"
    t.string   "frontcover_content_type"
    t.integer  "frontcover_file_size"
    t.datetime "frontcover_updated_at"
    t.string   "filename"
    t.string   "backcover_file_name"
    t.string   "backcover_content_type"
    t.integer  "backcover_file_size"
    t.datetime "backcover_updated_at"
    t.string   "console"
    t.string   "frontcoverlink"
    t.string   "backcoverlink"
    t.string   "filepath"
  end

end
