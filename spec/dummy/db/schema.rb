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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131017041939) do

  create_table "authors", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "pages", :force => true do |t|
    t.integer "user_id"
    t.string  "title"
    t.text    "content"
    t.boolean "approved",  :default => false
    t.string  "page_type"
    t.string  "position"
    t.integer "author_id"
  end

  create_table "subpages", :force => true do |t|
    t.integer  "page_id"
    t.string   "subtitle"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.text     "content"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "worth_saving_drafts", :force => true do |t|
    t.integer  "recordable_id"
    t.string   "recordable_type"
    t.integer  "scopeable_id"
    t.string   "scopeable_type"
    t.text     "form_data"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "worth_saving_drafts", ["recordable_id", "recordable_type"], :name => "worth_saving_draft_recordable_index"
  add_index "worth_saving_drafts", ["recordable_type", "scopeable_id", "scopeable_type"], :name => "worth_saving_draft_scopeable_index"

end
