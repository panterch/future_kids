require 'spec_helper'

describe DocumentsController do
  context 'as a mentor' do
    before(:each) do
      sign_in create(:mentor)
      create(:document, title: 'a1', category: 'a')
      create(:document, title: 'ax1', category: 'a', subcategory: 'x')
    end

    it 'can browse documents' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to match /a1/
      expect(response.body).to match /ax1/
    end

    it 'cannot destroy a document' do
      expect do
        delete :destroy, id: Document.first.id
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'as an admin' do
    before(:each) do
      sign_in create(:admin)
    end

    it 'creates a new document' do
      path = File.join(Rails.root, 'doc/gespraechsdoku.pdf')
      file = fixture_file_upload(path, 'application/pdf')
      post :create, document: { title: 't', category: 'c', attachment: file }
      expect(response).to redirect_to(action: 'index')
      expect(Document.first.title).to eq('t')
      expect(Document.first.attachment).to be_present
    end

    it 'destroys documents' do
      document = create(:document, title: 'a1', category: 'a')
      delete :destroy, id: document.id
      expect(response).to redirect_to(action: 'index')
      expect(Document.count).to eq(0)
    end
  end
end
