#require 'elasticsearch/model'

class Poem < ActiveRecord::Base
=begin
  include Elasticsearch::Model

  settings index: { number_of_shards: 1 } do
  mappings dynamic: 'false' do
    indexes :title, analyzer: 'russian'
    indexes :body, analyzer: 'russian'
  end
end
=end
  def self.searchable_language
    'russian'
  end
end

=begin
# Delete the previous articles index in Elasticsearch
Poem.__elasticsearch__.client.indices.delete index: Poem.index_name rescue nil

# Create the new index with the new mapping
Poem.__elasticsearch__.client.indices.create index: Poem.index_name,
  body: { settings: Poem.settings.to_hash, mappings: Poem.mappings.to_hash }

# Index all article records from the DB to Elasticsearch
Poem.import
=end
