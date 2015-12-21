class AddIndexOnQuestionBody < ActiveRecord::Migration
  def change
  	add_index :questions, :body, unique: true
  end
end
