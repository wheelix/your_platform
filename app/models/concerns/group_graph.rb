concern :GroupGraph do

  included do
    after_save :sync_to_graph_database
    before_destroy { Graph::Group.find(self).delete }
  end

  def sync_to_graph_database
    Graph::Group.sync self
  end

  def descendant_memberships
    Membership.where(id: Graph::Group.find(self).descendant_membership_ids)
  end

end
