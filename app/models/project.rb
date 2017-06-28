class Project < ActiveRecord::Base
  attr_accessor :corporation_name

  is_structureable ancestor_class_names: %w(Group Page), descendant_class_names: %w(Group Page)
  include Navable

  def group
    parent_groups.first
  end

end
