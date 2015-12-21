class AddIndexOnAnswersQuestionId < ActiveRecord::Migration
  def change
  	add_index :answers, [:question_id, :body], unique: true
  end
end
