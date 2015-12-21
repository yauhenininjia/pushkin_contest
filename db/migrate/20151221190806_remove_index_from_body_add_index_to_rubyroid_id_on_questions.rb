class RemoveIndexFromBodyAddIndexToRubyroidIdOnQuestions < ActiveRecord::Migration
  def change
  	remove_index :questions, :body
  	add_index :questions, :rubyroid_id, unique: true
  end
end
