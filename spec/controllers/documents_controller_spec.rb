require 'spec_helper'

describe DocumentsController do

  let(:file) { fixture_file_upload('gespraechsdoku.pdf', 'application/pdf') }

  context 'as a mentor' do
    before(:each) do
      sign_in create(:mentor)
      build(:document, title: 'a1', category0: 'a', admin_only: false).attachment.attach(file).record.save!
      build(:document, title: 'ax1', category0: 'a', category1: 'x', admin_only: true).attachment.attach(file).record.save!
    end

    it 'can browse non-admin documents' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to match /a1/
      expect(response.body).not_to match /ax1/
    end

    it 'cannot destroy a document' do
      expect do
        delete :destroy, params: { id: Document.first.id }
      end.to raise_error(CanCan::AccessDenied)
    end
  end

  context 'as an admin' do
    before(:each) do
      sign_in create(:admin)
      build(:document, title: 'a1', category0: 'a', admin_only: false).attachment.attach(file).record.save!
      build(:document, title: 'ax1', category0: 'a', category1: 'x', admin_only: true).attachment.attach(file).record.save!
    end

    it 'can browse all documents including admin-only ones' do
      get :index
      expect(response).to have_http_status(:ok)
      expect(response.body).to match /a1/
      expect(response.body).to match /ax1/
    end

    it 'creates a new document' do
      post :create, params: { document: { title: 't', category0: 'c', attachment: file, admin_only: true } }
      expect(response).to redirect_to(action: 'index')
      d = Document.find_by(title: 't')
      expect(d.category0).to eq('c')
      expect(d.admin_only).to eq(true)
      expect(d.attachment).to be_present
    end

    it 'destroys documents' do
      document = create(:document, title: 'a1', category0: 'a', attachment: file)
      document_id = document.id
      delete :destroy, params: { id: document_id }
      expect(response).to redirect_to(action: 'index')
      expect(Document.exists?(document_id)).to be false
    end
  end
end
