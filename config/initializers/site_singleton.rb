# assert that one and only one site model exists

Site.create! if ActiveRecord::Base.connection.table_exists?('sites') && !Site.exists?
