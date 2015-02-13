module InheritedResourceHelpers

  # mock url and other helper methods contributed by inherited resource
  def mock_inherited_resource(resource)
    allow(view).to receive(:collection_path).and_return('/collection_path')
    allow(view).to receive(:edit_resource_path).and_return('/edit_resource_path')
    allow(view).to receive(:new_resource_path).and_return('/new_resource_path')
    allow(view).to receive(:parent_path).and_return('/parent_path')
    allow(view).to receive(:resource_path).and_return('/resource_path')

    allow(view).to receive(:collection_url).and_return('/collection_url')
    allow(view).to receive(:edit_resource_url).and_return('/edit_resource_url')
    allow(view).to receive(:new_resource_url).and_return('/new_resource_url')
    allow(view).to receive(:parent_url).and_return('/parent_url')
    allow(view).to receive(:resource_url).and_return('/resource_url')

    allow(view).to receive(:collection).and_return([resource])
    allow(view).to receive(:resource).and_return(resource)
  end
end
