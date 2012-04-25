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

ActiveRecord::Schema.define(:version => 20120420051746) do

  create_table "acl_entries", :force => true do |t|
    t.string   "role",           :null => false
    t.integer  "subject_id",     :null => false
    t.string   "subject_type",   :null => false
    t.integer  "principal_id",   :null => false
    t.string   "principal_type", :null => false
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "acl_entries", ["principal_id", "principal_type", "subject_id", "subject_type"], :name => "index_acl_entries_by_principal_subject", :unique => true
  add_index "acl_entries", ["subject_id", "subject_type", "principal_id", "principal_type"], :name => "index_acl_entries_by_subject_principal", :unique => true

  create_table "blobs", :force => true do |t|
    t.integer "repository_id",                :null => false
    t.integer "size",                         :null => false
    t.string  "gitid",         :limit => 64,  :null => false
    t.string  "mime_type",     :limit => 256, :null => false
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
    t.integer "commit_id",                     :null => false
    t.integer "old_object_id"
    t.string  "old_object_type", :limit => 16
    t.integer "new_object_id"
    t.string  "new_object_type", :limit => 16
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

  create_table "credentials", :force => true do |t|
    t.integer "user_id",                                    :null => false
    t.string  "type",     :limit => 32,                     :null => false
    t.string  "name",     :limit => 128
    t.boolean "verified",                :default => false, :null => false
    t.binary  "key"
  end

  add_index "credentials", ["type", "name"], :name => "index_credentials_on_type_and_name", :unique => true
  add_index "credentials", ["user_id", "type"], :name => "index_credentials_on_user_id_and_type"

  create_table "feed_item_topics", :force => true do |t|
    t.integer  "feed_item_id", :null => false
    t.integer  "topic_id",     :null => false
    t.string   "topic_type",   :null => false
    t.datetime "created_at"
  end

  add_index "feed_item_topics", ["feed_item_id"], :name => "index_feed_item_topics_on_feed_item_id"
  add_index "feed_item_topics", ["topic_id", "topic_type", "created_at"], :name => "index_feed_item_topics_on_topic_id_and_topic_type_and_created_at"
  add_index "feed_item_topics", ["topic_id", "topic_type", "feed_item_id"], :name => "index_feed_item_topics_on_topic_item", :unique => true

  create_table "feed_items", :force => true do |t|
    t.integer  "author_id",   :null => false
    t.string   "verb",        :null => false
    t.integer  "target_id",   :null => false
    t.string   "target_type", :null => false
    t.text     "data"
    t.datetime "created_at"
  end

  add_index "feed_items", ["author_id"], :name => "index_feed_items_on_author_id"

  create_table "feed_subscriptions", :force => true do |t|
    t.integer  "profile_id",               :null => false
    t.integer  "topic_id",                 :null => false
    t.string   "topic_type", :limit => 16, :null => false
    t.datetime "created_at"
  end

  add_index "feed_subscriptions", ["profile_id", "topic_id", "topic_type"], :name => "index_feed_subscriptions_on_profile_topic", :unique => true
  add_index "feed_subscriptions", ["topic_id", "topic_type", "profile_id"], :name => "index_feed_subscriptions_on_topic_profile", :unique => true

  create_table "issues", :force => true do |t|
    t.integer  "repository_id",                                   :null => false
    t.integer  "author_id",                                       :null => false
    t.boolean  "open",                         :default => true,  :null => false
    t.boolean  "sensitive",                    :default => false, :null => false
    t.string   "title",         :limit => 160,                    :null => false
    t.text     "description",                                     :null => false
    t.integer  "exid",                                            :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "issues", ["author_id", "open"], :name => "index_issues_on_author_id_and_open"
  add_index "issues", ["repository_id", "exid"], :name => "index_issues_on_repository_id_and_exid", :unique => true
  add_index "issues", ["repository_id", "open"], :name => "index_issues_on_repository_id_and_open"

  create_table "profiles", :force => true do |t|
    t.string   "name",          :limit => 32,  :null => false
    t.string   "display_name",  :limit => 128, :null => false
    t.string   "display_email", :limit => 128
    t.string   "blog",          :limit => 128
    t.string   "company",       :limit => 128
    t.string   "city",          :limit => 128
    t.string   "language",      :limit => 64
    t.text     "about"
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
  end

  add_index "profiles", ["name"], :name => "index_profiles_on_name", :unique => true

  create_table "repositories", :force => true do |t|
    t.integer  "profile_id",                                    :null => false
    t.string   "name",        :limit => 64,                     :null => false
    t.text     "description"
    t.string   "url",         :limit => 256
    t.boolean  "public",                     :default => false, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "repositories", ["profile_id", "name"], :name => "index_repositories_on_profile_id_and_name", :unique => true

  create_table "ssh_keys", :force => true do |t|
    t.string   "fprint",     :limit => 128, :null => false
    t.integer  "user_id",                   :null => false
    t.string   "name",       :limit => 128, :null => false
    t.text     "key_line",                  :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "ssh_keys", ["fprint"], :name => "index_ssh_keys_on_fprint", :unique => true
  add_index "ssh_keys", ["user_id"], :name => "index_ssh_keys_on_user_id"

  create_table "submodules", :force => true do |t|
    t.integer "repository_id",                :null => false
    t.string  "name",          :limit => 128, :null => false
    t.string  "gitid",         :limit => 64,  :null => false
  end

  add_index "submodules", ["repository_id", "name", "gitid"], :name => "index_submodules_on_repository_id_and_name_and_gitid", :unique => true

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
    t.string  "child_type", :limit => 16,  :null => false
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
    t.string   "exuid",      :limit => 32,                    :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.integer  "profile_id"
    t.boolean  "admin",                    :default => false, :null => false
  end

  add_index "users", ["exuid"], :name => "index_users_on_exuid", :unique => true
  add_index "users", ["profile_id"], :name => "index_users_on_profile_id", :unique => true

end
