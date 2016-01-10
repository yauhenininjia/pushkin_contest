class AddIndexForFullTextSearchOnPoemTitle < ActiveRecord::Migration
  def change
  	execute "
    	create index on poems using gin(to_tsvector('russian', title))"
  end
end
