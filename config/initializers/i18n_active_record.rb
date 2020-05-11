# enable host specific translations via AR records
#
# to insert a new translation use the store translations method
#
# example:
# I18n::Backend::ActiveRecord.new.store_translations(:de, nav: { kid: 'Kid AR'})
require 'i18n/backend/active_record'

if (::ActiveRecord::Base.connection_pool.with_connection(&:active?) rescue false) &&
    I18n::Backend::ActiveRecord::Translation.table_exists?

  I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n.backend)
  Translation  = I18n::Backend::ActiveRecord::Translation

end