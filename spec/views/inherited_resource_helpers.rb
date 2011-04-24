module InheritedResourceHelpers

  # mock url and other helper methods contributed by inherited resource
  def mock_inherited_resource(resource)
    view.stub(:collection_path).and_return('/collection_path')
    view.stub(:edit_resource_path).and_return('/edit_resource_path')
    view.stub(:new_resource_path).and_return('/new_resource_path')
    view.stub(:parent_path).and_return('/parent_path')
    view.stub(:resource_path).and_return('/resource_path')

    view.stub(:collection_url).and_return('/collection_url')
    view.stub(:edit_resource_url).and_return('/edit_resource_url')
    view.stub(:new_resource_url).and_return('/new_resource_url')
    view.stub(:parent_url).and_return('/parent_url')
    view.stub(:resource_url).and_return('/resource_url')

    view.stub(:collection).and_return([resource])
    view.stub(:resource).and_return(resource)
  end
end
