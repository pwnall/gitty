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

ActiveRecord::Schema.define(:version => 20101013232422) do

  create_table "acl_entries", :force => true do |t|
    t.string   "role",           :null => false
    t.integer  "subject_id",     :null => false
    t.string   "subject_type",   :null => false
    t.integer  "principal_id",   :null => false
    t.string   "principal_type", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blobs", :force => true do |t|
    t.integer "repository_id",               :null => false
    t.string  "gitid",         :limit => 64, :null => false
    t.string  "mime_type",     :limit => 64, :null => false
    t.integer "size",                        :null => false
  end

  add_index "blobs", ["repository_id", "gitid"], :name => "index_blobs_on_repository_id_and_gitid", :unique => true

  create_table "branches", :force => true do |t|
    t.string  "name",          :limit => 128, :null => false
    t.integer "repository_id",                :null => false
    t.integer "commit_id",                    :null => false
  end

  add_index "branches", ["repository_id", "name"], :name => "index_branches_on_repository_id_and_name", :unique => true

  create_table "commit_diff_hunks", :force => true do |t|
    t.integer "diff_id",   :null => false
    t.integer "old_start", :null => false
    t.integer "old_count", :null => false
    t.integer "new_start", :null => false
    t.integer "new_count", :null => false
    t.text    "context"
    t.text    "summary"
  end

  add_index "commit_diff_hunks", ["diff_id", "old_start", "new_start"], :name => "index_commit_diff_hunks_on_diff_id_and_old_start_and_new_start", :unique => true
  add_index "commit_diff_hunks", ["diff_id"], :name => "index_commit_diff_hunks_on_diff_id"

  create_table "commit_diffs", :force => true do |t|
    t.integer "commit_id",   :null => false
    t.integer "old_blob_id"
    t.integer "new_blob_id"
    t.string  "old_path"
    t.string  "new_path"
  end

  add_index "commit_diffs", ["commit_id"], :name => "index_commit_diffs_on_commit_id"

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

  create_table "config_vars", :force => true do |t|
    t.string "name",  :null => false
    t.binary "value", :null => false
  end

  add_index "config_vars", ["name"], :name => "index_config_vars_on_name", :unique => true

  create_table "facebook_tokens", :force => true do |t|
    t.integer "user_id",                     :null => false
    t.string  "external_uid", :limit => 32,  :null => false
    t.string  "access_token", :limit => 128, :null => false
  end

  add_index "facebook_tokens", ["external_uid"], :name => "index_facebook_tokens_on_external_uid", :unique => true

  create_table "profiles", :force => true do |t|
    t.string   "name",         :limit => 32,  :null => false
    t.string   "display_name", :limit => 128, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "profiles", ["name"], :name => "index_profiles_on_name", :unique => true

  create_table "repositories", :force => true do |t|
    t.integer  "profile_id",                                    :null => false
    t.string   "name",        :limit => 64,                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
    t.string   "url",         :limit => 256
    t.boolean  "public",                     :default => false, :null => false
  end

  add_index "repositories", ["profile_id", "name"], :name => "index_repositories_on_profile_id_and_name", :unique => true

  create_table "ssh_keys", :force => true do |t|
    t.string   "fprint",     :limit => 128, :null => false
    t.integer  "user_id",                   :null => false
    t.string   "name",       :limit => 128, :null => false
    t.text     "key_line",                  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ssh_keys", ["fprint"], :name => "index_ssh_keys_on_fprint", :unique => true
  add_index "ssh_keys", ["user_id"], :name => "index_ssh_keys_on_user_id"

  create_table "tags", :force => true do |t|
    t.string   "name",            :limit => 128, :null => false
    t.integer  "repository_id",                  :null => false
    t.integer  "commit_id",                      :null => false
    t.string   "committer_name",  :limit => 128, :null => false
    t.string   "committer_email", :limit => 128, :null => false
    t.datetime "committed_at",                   :null => false
    t.text     "message",                        :null => false
  end

  add_index "tags", ["repository_id", "name"], :name => "index_tags_on_repository_id_and_name", :unique => true

  create_table "tree_entries", :force => true do |t|
    t.integer "tree_id",                   :null => false
    t.string  "child_type", :limit => 8,   :null => false
    t.integer "child_id",                  :null => false
    t.string  "name",       :limit => 128, :null => false
  end

  add_index "tree_entries", ["tree_id", "name"], :name => "index_tree_entries_on_tree_id_and_name", :unique => true

  create_table "trees", :force => true do |t|
    t.integer "repository_id"
    t.string  "gitid",         :limit => 64, :null => false
  end

  add_index "trees", ["repository_id", "gitid"], :name => "index_trees_on_repository_id_and_gitid", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",         :limit => 64, :null => false
    t.string   "password_salt", :limit => 16
    t.string   "password_hash", :limit => 64
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["profile_id"], :name => "index_users_on_profile_id", :unique => true

end
