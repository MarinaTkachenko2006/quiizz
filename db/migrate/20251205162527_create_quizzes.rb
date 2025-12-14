class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes do |t|
      t.string :title, null: false
      t.string :description
      t.integer :author_id, null: false
      t.string :code, null: false
      t.timestamps

      t.index :title, unique: true
      t.index :code, unique: true
    end

    create_table :questions do |t|
      t.integer :quiz_id, null: false
      t.string :text, null: false
      t.integer :time_limit, null: false
      t.integer :reward, null: false
      t.integer :order_index, null: false
      t.timestamps
    end

    create_table :answers do |t|
      t.integer :question_id, null: false
      t.string :answer_text, null: false
      t.boolean :is_correct, null: false
      t.timestamps
    end

  end
end
