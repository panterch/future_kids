require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Posts Page", %q{
  In order to have many posts
  I want to start creating a post first
} do

  scenario "should create new post" do
    post = Factory.build(:post)
    visit '/posts/new'

    fill_in 'post_title', :with => post.title
    fill_in 'post_body', :with => post.body
    click_button 'Create Post'

    current_path.should match %r{/posts/\d+}
    page.should have_content(post.title) if post.title
    page.should have_content(post.body) if post.body
  end

  scenario "should show post index" do
    attributes = Factory.attributes_for(:post)
    Post.create!(attributes)

    visit posts_url
    values = attributes.collect{|k,v| v}
    values.each do |value|
      page.should have_content(value)
    end
  end
end
