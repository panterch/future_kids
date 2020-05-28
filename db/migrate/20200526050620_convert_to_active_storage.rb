class ConvertToActiveStorage < ActiveRecord::Migration[5.2]
  require 'open-uri'

  def up
    # postgres
    get_blob_id = 'LASTVAL()'
    # mariadb
    # get_blob_id = 'LAST_INSERT_ID()'
    # sqlite
    # get_blob_id = 'LAST_INSERT_ROWID()'

    active_storage_blob_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_blob_statement', <<-SQL)
      INSERT INTO active_storage_blobs (
        key, filename, content_type, metadata, byte_size, checksum, created_at
      ) VALUES ($1, $2, $3, '{}', $4, $5, $6)
    SQL

    active_storage_attachment_statement = ActiveRecord::Base.connection.raw_connection.prepare('active_storage_attachment_statement', <<-SQL)
      INSERT INTO active_storage_attachments (
        name, record_type, record_id, blob_id, created_at
      ) VALUES ($1, $2, $3, #{"(SELECT max(id) from active_storage_blobs)"}, $4)
    SQL

    Rails.application.eager_load!
    models = ActiveRecord::Base.descendants.reject(&:abstract_class?)

    transaction do
      models.each do |model|
        attachments = model.column_names.map do |c|
          if c =~ /(.+)_file_name$/
            $1
          end
        end.compact

        if attachments.blank?
          next
        end

        model.find_each.each do |instance|
          attachments.each do |attachment|
            filename = instance.send("#{attachment}_file_name")
            full_path = "#{Rails.root}/public/system/#{ActiveSupport::Inflector.pluralize(attachment)}/#{instance.id}/original/#{filename.to_s}"
            if filename.blank? || !File.file?(full_path)
              next
            end
            ActiveRecord::Base.connection.raw_connection.exec_prepared(
              'active_storage_blob_statement', [
                key(instance, attachment),
                filename,
                instance.send("#{attachment}_content_type"),
                instance.send("#{attachment}_file_size"),
                checksum(full_path),
                instance.send("#{attachment}_updated_at").iso8601
              ])

            ActiveRecord::Base.connection.raw_connection.exec_prepared(
              'active_storage_attachment_statement', [
                attachment,
                model.name,
                instance.id,
                instance.send("#{attachment}_updated_at").iso8601,
              ])
          end
        end
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def key(instance, attachment)
    SecureRandom.uuid
    # Alternatively:
    # instance.send("#{attachment}_file_name")
  end

  def checksum(filename)
    # local files stored on disk:
    Digest::MD5.base64digest(File.read(filename))

    # remote files stored on another person's computer:
    # url = attachment.url
    # Digest::MD5.base64digest(Net::HTTP.get(URI(url)))
  end
end