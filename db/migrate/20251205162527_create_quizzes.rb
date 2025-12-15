class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes, id: false do |t|
      t.string :id, primary_key: true, null: false
      t.string :title, null: false
      t.string :description
      t.integer :author_id, null: false
      t.datetime :created_at, null: false

      t.index :title
    end

    create_table :questions do |t|
      t.string :quiz_id, null: false
      t.string :text, null: false
      t.integer :time_limit, null: false
      t.integer :reward, null: false
      t.integer :order_index, null: false
    end

    create_table :answers do |t|
      t.integer :question_id, null: false
      t.string :answer_text, null: false
      t.boolean :is_correct, null: false
    end

    add_foreign_key :questions, :quizzes
    add_foreign_key :answers, :questions
  end
end
