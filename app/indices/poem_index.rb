ThinkingSphinx::Index.define :poem, :with => :active_record do
  # fields
  indexes body

  # attributes
  #has author_id, created_at, updated_at
end