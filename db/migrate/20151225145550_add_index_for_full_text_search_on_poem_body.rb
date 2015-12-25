class AddIndexForFullTextSearchOnPoemBody < ActiveRecord::Migration
  def change
  	execute "
    	create index on poems using gin(to_tsvector('russian', body))"
  end
end
