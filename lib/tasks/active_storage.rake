namespace :active_storage do
  desc "ActiveStorage actions"
  task move_paperclip_files: :environment do
    ActiveStorage::Attachment.find_each do |attachment|
      name = attachment.name
      filename = attachment.blob.filename

      source = "#{Rails.root}/public/system/#{ActiveSupport::Inflector.pluralize(name)}/#{attachment.record_id}/original/#{filename}"
      dest_dir = File.join(
        "storage",
        attachment.blob.key.first(2),
        attachment.blob.key.first(4).last(2))
      dest = File.join(dest_dir, attachment.blob.key)

      FileUtils.mkdir_p(dest_dir)
      puts "Moving #{source} to #{dest}"
      FileUtils.cp(source, dest)
    end
  end

  def migrate(from, to)
    config_file = Pathname.new(Rails.root.join("config/storage.yml"))
    configs = YAML.load(ERB.new(config_file.read).result) || {}

    from_service = ActiveStorage::Service.configure from, configs
    to_service   = ActiveStorage::Service.configure to, configs

    ActiveStorage::Blob.service = from_service

    puts "#{ActiveStorage::Blob.count} Blobs to go..."

    ActiveStorage::Blob.find_each do |blob|
      print '.'
      file = Tempfile.new("file#{Time.now.to_f}")
      file.binmode
      file << blob.download
      file.rewind
      checksum = blob.checksum
      to_service.upload(blob.key, file, checksum: checksum)
    rescue Errno::ENOENT
      puts "Rescued by Errno::ENOENT statement. ID: #{blob.id} / Key: #{blob.key}"
      next
    rescue ActiveStorage::FileNotFoundError
      puts "Rescued by FileNotFoundError. ID: #{blob.id} / Key: #{blob.key}"
      next
    end
  end

  task migrate_to_s3: :environment do
    migrate(:local, :google)
  end
end
