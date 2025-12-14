class CreateQuizSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_sessions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :score, default: 0
      t.integer :number_correct_answers, default: 0
      t.boolean :is_completed, default: false

      t.timestamps
    end
  end
end
