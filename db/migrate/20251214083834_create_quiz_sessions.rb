class CreateQuizSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_sessions do |t|
      t.string :quiz_id, null: false
      t.integer :user_id, null: false
      t.integer :score, default: 0
      t.integer :number_correct_answers, default: 0
      t.boolean :is_completed, default: false
    end

    add_foreign_key :quiz_sessions, :quizzes
    add_foreign_key :quiz_sessions, :users
  end
end
