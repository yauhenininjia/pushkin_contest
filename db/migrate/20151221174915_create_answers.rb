class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.string :body
      t.references :question, index: true, foreign_key: true
      t.integer :level

      t.timestamps null: false
    end
  end
end
