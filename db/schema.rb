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

ActiveRecord::Schema.define(version: 20120420051746) do

  create_table "acl_entries", force: :cascade do |t|
    t.string   "role",           limit: 255, null: false
    t.integer  "subject_id",     limit: 4,   null: false
    t.string   "subject_type",   limit: 255, null: false
    t.integer  "principal_id",   limit: 4,   null: false
    t.string   "principal_type", limit: 255, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "acl_entries", ["principal_id", "principal_type", "subject_id", "subject_type"], name: "index_acl_entries_by_principal_subject", unique: true, using: :btree
  add_index "acl_entries", ["subject_id", "subject_type", "principal_id", "principal_type"], name: "index_acl_entries_by_subject_principal", unique: true, using: :btree

  create_table "blobs", force: :cascade do |t|
    t.integer "repository_id", limit: 4,   null: false
    t.integer "size",          limit: 4,   null: false
    t.string  "gitid",         limit: 64,  null: false
    t.string  "mime_type",     limit: 256, null: false
  end

  add_index "blobs", ["repository_id", "gitid"], name: "index_blobs_on_repository_id_and_gitid", unique: true, using: :btree

  create_table "branches", force: :cascade do |t|
    t.string  "name",          limit: 128, null: false
    t.integer "repository_id", limit: 4,   null: false
    t.integer "commit_id",     limit: 4,   null: false
  end

  add_index "branches", ["repository_id", "name"], name: "index_branches_on_repository_id_and_name", unique: true, using: :btree

  create_table "commit_diff_hunks", force: :cascade do |t|
    t.integer "diff_id",   limit: 4,     null: false
    t.integer "old_start", limit: 4,     null: false
    t.integer "old_count", limit: 4,     null: false
    t.integer "new_start", limit: 4,     null: false
    t.integer "new_count", limit: 4,     null: false
    t.text    "context",   limit: 65535
    t.text    "summary",   limit: 65535
  end

  add_index "commit_diff_hunks", ["diff_id", "old_start", "new_start"], name: "index_commit_diff_hunks_on_diff_id_and_old_start_and_new_start", unique: true, using: :btree
  add_index "commit_diff_hunks", ["diff_id"], name: "index_commit_diff_hunks_on_diff_id", using: :btree

  create_table "commit_diffs", force: :cascade do |t|
    t.integer "commit_id",       limit: 4,   null: false
    t.integer "old_object_id",   limit: 4
    t.string  "old_object_type", limit: 16
    t.integer "new_object_id",   limit: 4
    t.string  "new_object_type", limit: 16
    t.string  "old_path",        limit: 255
    t.string  "new_path",        limit: 255
  end

  add_index "commit_diffs", ["commit_id"], name: "index_commit_diffs_on_commit_id", using: :btree

  create_table "commit_parents", force: :cascade do |t|
    t.integer "commit_id", limit: 4, null: false
    t.integer "parent_id", limit: 4, null: false
  end

  add_index "commit_parents", ["commit_id", "parent_id"], name: "index_commit_parents_on_commit_id_and_parent_id", unique: true, using: :btree

  create_table "commits", force: :cascade do |t|
    t.integer  "repository_id",   limit: 4,     null: false
    t.string   "gitid",           limit: 64,    null: false
    t.integer  "tree_id",         limit: 4,     null: false
    t.string   "author_name",     limit: 128,   null: false
    t.string   "author_email",    limit: 128,   null: false
    t.string   "committer_name",  limit: 128,   null: false
    t.string   "committer_email", limit: 128,   null: false
    t.datetime "authored_at",                   null: false
    t.datetime "committed_at",                  null: false
    t.text     "message",         limit: 65535, null: false
  end

  add_index "commits", ["repository_id", "gitid"], name: "index_commits_on_repository_id_and_gitid", unique: true, using: :btree

  create_table "config_vars", force: :cascade do |t|
    t.string "name",  limit: 255,   null: false
    t.binary "value", limit: 65535, null: false
  end

  add_index "config_vars", ["name"], name: "index_config_vars_on_name", unique: true, using: :btree

  create_table "credentials", force: :cascade do |t|
    t.integer  "user_id",    limit: 4,    null: false
    t.string   "type",       limit: 32,   null: false
    t.string   "name",       limit: 128
    t.datetime "updated_at",              null: false
    t.binary   "key",        limit: 2048
  end

  add_index "credentials", ["type", "name"], name: "index_credentials_on_type_and_name", unique: true, using: :btree
  add_index "credentials", ["type", "updated_at"], name: "index_credentials_on_type_and_updated_at", using: :btree
  add_index "credentials", ["user_id", "type"], name: "index_credentials_on_user_id_and_type", using: :btree

  create_table "feed_item_topics", force: :cascade do |t|
    t.integer  "feed_item_id", limit: 4,   null: false
    t.integer  "topic_id",     limit: 4,   null: false
    t.string   "topic_type",   limit: 255, null: false
    t.datetime "created_at"
  end

  add_index "feed_item_topics", ["feed_item_id"], name: "index_feed_item_topics_on_feed_item_id", using: :btree
  add_index "feed_item_topics", ["topic_id", "topic_type", "created_at"], name: "index_feed_item_topics_on_topic_id_and_topic_type_and_created_at", using: :btree
  add_index "feed_item_topics", ["topic_id", "topic_type", "feed_item_id"], name: "index_feed_item_topics_on_topic_item", unique: true, using: :btree

  create_table "feed_items", force: :cascade do |t|
    t.integer  "author_id",   limit: 4,     null: false
    t.string   "verb",        limit: 255,   null: false
    t.integer  "target_id",   limit: 4,     null: false
    t.string   "target_type", limit: 255,   null: false
    t.text     "data",        limit: 65535
    t.datetime "created_at"
  end

  add_index "feed_items", ["author_id"], name: "index_feed_items_on_author_id", using: :btree

  create_table "feed_subscriptions", force: :cascade do |t|
    t.integer  "profile_id", limit: 4,  null: false
    t.integer  "topic_id",   limit: 4,  null: false
    t.string   "topic_type", limit: 16, null: false
    t.datetime "created_at"
  end

  add_index "feed_subscriptions", ["profile_id", "topic_id", "topic_type"], name: "index_feed_subscriptions_on_profile_topic", unique: true, using: :btree
  add_index "feed_subscriptions", ["topic_id", "topic_type", "profile_id"], name: "index_feed_subscriptions_on_topic_profile", unique: true, using: :btree

  create_table "issues", force: :cascade do |t|
    t.integer  "repository_id", limit: 4,                     null: false
    t.integer  "author_id",     limit: 4,                     null: false
    t.boolean  "open",                        default: true,  null: false
    t.boolean  "sensitive",                   default: false, null: false
    t.string   "title",         limit: 160,                   null: false
    t.text     "description",   limit: 65535,                 null: false
    t.integer  "number",        limit: 4,                     null: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "issues", ["author_id", "open"], name: "index_issues_on_author_id_and_open", using: :btree
  add_index "issues", ["repository_id", "number"], name: "index_issues_on_repository_id_and_number", unique: true, using: :btree
  add_index "issues", ["repository_id", "open", "number"], name: "index_issues_on_repository_id_and_open_and_number", unique: true, using: :btree

  create_table "profiles", force: :cascade do |t|
    t.string   "name",          limit: 32,    null: false
    t.string   "display_name",  limit: 128,   null: false
    t.string   "display_email", limit: 128
    t.string   "blog",          limit: 128
    t.string   "company",       limit: 128
    t.string   "city",          limit: 128
    t.string   "language",      limit: 64
    t.text     "about",         limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "profiles", ["name"], name: "index_profiles_on_name", unique: true, using: :btree

  create_table "repositories", force: :cascade do |t|
    t.integer  "profile_id",  limit: 4,                     null: false
    t.string   "name",        limit: 64,                    null: false
    t.text     "description", limit: 65535
    t.string   "url",         limit: 256
    t.boolean  "public",                    default: false, null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "repositories", ["profile_id", "name"], name: "index_repositories_on_profile_id_and_name", unique: true, using: :btree

  create_table "ssh_keys", force: :cascade do |t|
    t.string   "fprint",     limit: 128,   null: false
    t.integer  "user_id",    limit: 4,     null: false
    t.string   "name",       limit: 128,   null: false
    t.text     "key_line",   limit: 65535, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "ssh_keys", ["fprint"], name: "index_ssh_keys_on_fprint", unique: true, using: :btree
  add_index "ssh_keys", ["user_id"], name: "index_ssh_keys_on_user_id", using: :btree

  create_table "submodules", force: :cascade do |t|
    t.integer "repository_id", limit: 4,   null: false
    t.string  "name",          limit: 128, null: false
    t.string  "gitid",         limit: 64,  null: false
  end

  add_index "submodules", ["repository_id", "name", "gitid"], name: "index_submodules_on_repository_id_and_name_and_gitid", unique: true, using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",            limit: 128,   null: false
    t.integer  "repository_id",   limit: 4,     null: false
    t.integer  "commit_id",       limit: 4,     null: false
    t.string   "committer_name",  limit: 128,   null: false
    t.string   "committer_email", limit: 128,   null: false
    t.datetime "committed_at",                  null: false
    t.text     "message",         limit: 65535, null: false
  end

  add_index "tags", ["repository_id", "name"], name: "index_tags_on_repository_id_and_name", unique: true, using: :btree

  create_table "tree_entries", force: :cascade do |t|
    t.integer "tree_id",    limit: 4,   null: false
    t.string  "child_type", limit: 16,  null: false
    t.integer "child_id",   limit: 4,   null: false
    t.string  "name",       limit: 128, null: false
  end

  add_index "tree_entries", ["tree_id", "name"], name: "index_tree_entries_on_tree_id_and_name", using: :btree

  create_table "trees", force: :cascade do |t|
    t.integer "repository_id", limit: 4,  null: false
    t.string  "gitid",         limit: 64, null: false
  end

  add_index "trees", ["repository_id", "gitid"], name: "index_trees_on_repository_id_and_gitid", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "exuid",      limit: 32,                 null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "profile_id", limit: 4
    t.boolean  "admin",                 default: false
  end

  add_index "users", ["exuid"], name: "index_users_on_exuid", unique: true, using: :btree
  add_index "users", ["profile_id"], name: "index_users_on_profile_id", unique: true, using: :btree

end
