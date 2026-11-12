# frozen_string_literal: true

# The site specific CSS is no longer used. It was put unescaped into a <style>
# tag on every page, the sign in page included, so whoever could edit the site
# settings could add script to all of them.
class RemoveCssFromSites < ActiveRecord::Migration[8.1]
  def change
    remove_column :sites, :css, :text
  end
end
