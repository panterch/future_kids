require 'spec_helper'

describe PostsController do

  context 'GET on new' do
    before(:each) { get :new }
    it 'assigns a new post record' do
      assigns(:post).should be_a_new(Post)
    end
    it 'responds with success' do
      response.code.should eq('200')
    end
  end
  
  context 'POST on create' do
    before(:each) { post :create, :post => Factory.attributes_for(:post) }
    it('responds with a redirect') { response.code.should eq('302') }
    it('creates a new post') { assigns(:post).should_not be_a_new_record }
  end

  context 'persisted post' do
    let(:post) { Factory(:post) }
    context 'GET on edit' do
      before(:each) { get :edit, :id => post }
      it('respons with success'){ response.code.should eq('200') }
    end
    context 'GET on index' do
      before(:each) { get :index }
      it('respons with success'){ response.code.should eq('200') }
      it('assigns posts'){ assigns(:posts).should eq([post]) }
    end
  end


end
