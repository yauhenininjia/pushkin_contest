#require 'elasticsearch/model'

class Poem < ActiveRecord::Base
  def self.searchable_language
    'russian'
  end
end
