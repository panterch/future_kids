require 'spec_helper'
include InheritedResourceHelpers

describe "posts/edit.html.haml" do
  before(:each) do
    @post = Factory(:post)
    mock_inherited_resource(@post)
    render
  end

  it "displays the text attribute of the post" do
    rendered.should =~ /#{@post.title}/
  end

  it "should not be the form to new" do
    rendered.should_not =~ /new_post/
  end

end
