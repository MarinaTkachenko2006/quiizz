# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2025_12_14_083834) do
  create_table "answers", force: :cascade do |t|
    t.string "answer_text", null: false
    t.datetime "created_at", null: false
    t.boolean "is_correct", null: false
    t.integer "question_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "questions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_index", null: false
    t.string "quiz_id", null: false
    t.integer "reward", null: false
    t.string "text", null: false
    t.integer "time_limit", null: false
    t.datetime "updated_at", null: false
  end

  create_table "quiz_sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "is_completed", default: false
    t.integer "number_correct_answers", default: 0
    t.string "quiz_id", null: false
    t.integer "score", default: 0
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
  end

  create_table "quizzes", id: :string, force: :cascade do |t|
    t.integer "author_id", null: false
    t.datetime "created_at", null: false
    t.string "description"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_quizzes_on_title"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "created_time", default: -> { "CURRENT_TIMESTAMP" }
    t.string "email", null: false
    t.string "nickname", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["nickname"], name: "index_users_on_nickname", unique: true
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "questions", "quizzes"
  add_foreign_key "quiz_sessions", "quizzes"
  add_foreign_key "quiz_sessions", "users"
end
