require 'spec_helper'
include InheritedResourceHelpers

describe "posts/new.html.haml" do
  before do
    @post = Factory.build(:post)
    mock_inherited_resource(@post)
    render
  end

  it "displays the text attribute of the post" do
    rendered.should =~ /#{@post.title}/
  end

end
