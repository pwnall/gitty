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

ActiveRecord::Schema.define(:version => 20100715071003) do

  create_table "blobs", :force => true do |t|
    t.integer "repository_id",               :null => false
    t.string  "gitid",         :limit => 64, :null => false
  end

  add_index "blobs", ["repository_id", "gitid"], :name => "index_blobs_on_repository_id_and_gitid", :unique => true

  create_table "branches", :force => true do |t|
    t.string  "name",          :limit => 128, :null => false
    t.integer "repository_id",                :null => false
    t.integer "commit_id",                    :null => false
  end

  add_index "branches", ["repository_id", "name"], :name => "index_branches_on_repository_id_and_name", :unique => true

  create_table "commit_parents", :force => true do |t|
    t.integer "commit_id", :null => false
    t.integer "parent_id", :null => false
  end

  add_index "commit_parents", ["commit_id", "parent_id"], :name => "index_commit_parents_on_commit_id_and_parent_id", :unique => true

  create_table "commits", :force => true do |t|
    t.integer  "repository_id",                  :null => false
    t.string   "gitid",           :limit => 64,  :null => false
    t.integer  "tree_id",                        :null => false
    t.string   "author_name",     :limit => 128, :null => false
    t.string   "author_email",    :limit => 128, :null => false
    t.string   "committer_name",  :limit => 128, :null => false
    t.string   "committer_email", :limit => 128, :null => false
    t.datetime "authored_at",                    :null => false
    t.datetime "committed_at",                   :null => false
    t.text     "message",                        :null => false
  end

  add_index "commits", ["repository_id", "gitid"], :name => "index_commits_on_repository_id_and_gitid", :unique => true

  create_table "config_flags", :force => true do |t|
    t.string "name",  :null => false
    t.binary "value", :null => false
  end

  add_index "config_flags", ["name"], :name => "index_config_flags_on_name", :unique => true

  create_table "profiles", :force => true do |t|
    t.string   "name",         :limit => 32,  :null => false
    t.string   "display_name", :limit => 128, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["name"], :name => "index_profiles_on_name", :unique => true

  create_table "repositories", :force => true do |t|
    t.integer  "profile_id",               :null => false
    t.string   "name",       :limit => 64, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "repositories", ["profile_id", "name"], :name => "index_repositories_on_profile_id_and_name", :unique => true

  create_table "ssh_keys", :force => true do |t|
    t.string   "fprint",     :limit => 128, :null => false
    t.integer  "profile_id",                :null => false
    t.string   "name",       :limit => 128, :null => false
    t.text     "key_line",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ssh_keys", ["fprint"], :name => "index_ssh_keys_on_fprint", :unique => true
  add_index "ssh_keys", ["profile_id"], :name => "index_ssh_keys_on_profile_id"

  create_table "tree_entries", :force => true do |t|
    t.integer "tree_id",                   :null => false
    t.string  "child_type", :limit => 8,   :null => false
    t.integer "child_id",                  :null => false
    t.string  "name",       :limit => 128, :null => false
  end

  add_index "tree_entries", ["tree_id", "child_type", "child_id"], :name => "index_tree_entries_on_tree_id_and_child_type_and_child_id", :unique => true
  add_index "tree_entries", ["tree_id", "name"], :name => "index_tree_entries_on_tree_id_and_name", :unique => true

  create_table "trees", :force => true do |t|
    t.integer "repository_id"
    t.string  "gitid",         :limit => 64, :null => false
  end

  add_index "trees", ["repository_id", "gitid"], :name => "index_trees_on_repository_id_and_gitid", :unique => true

end
