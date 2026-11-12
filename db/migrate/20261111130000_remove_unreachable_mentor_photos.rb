# frozen_string_literal: true

# When uploads moved from Paperclip to Active Storage (2020) the photos of
# mentors were attached under the type name "Mentor". The app looks photos up
# under "User", the base class of all user types, so it never reads these
# attachments; each of the users has a second photo it does read. Deleting a
# user removed only that one and left this copy in the file storage.
class RemoveUnreachableMentorPhotos < ActiveRecord::Migration[8.1]
  # files are deleted on the storage service, which must not happen inside a
  # transaction (see ActiveStorage::Blob#purge)
  disable_ddl_transaction!

  def up
    ActiveStorage::Attachment.where(record_type: 'Mentor', name: 'photo').find_each do |attachment|
      # only copies are removed: without a photo the app does read, this is the
      # only picture left of that user (or of a user deleted since) and stays
      unless ActiveStorage::Attachment.exists?(record_type: 'User', name: 'photo', record_id: attachment.record_id)
        say "kept attachment #{attachment.id}: the only photo of user #{attachment.record_id}"
        next
      end

      blob = attachment.blob
      if blob.attachments.where.not(id: attachment.id).exists?
        # the file is also attached to a record the app can reach: keep it
        attachment.delete
      else
        # the file first: if the storage service fails, the records are still
        # there and the migration can be run again. Blob#purge deletes the
        # records first and would leave a file nobody knows about
        blob.delete
        attachment.delete
        blob.destroy!
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
