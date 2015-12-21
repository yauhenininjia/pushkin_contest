class CreateAnswerGenerators < ActiveRecord::Migration
  def change
    create_table :answer_generators do |t|

      t.timestamps null: false
    end
  end
end
