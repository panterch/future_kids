# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
Mime::Type.register 'text/markdown', :md

# ERB HTML-escapes interpolated values by default; the escape_ignore_list
# opts specific mime types out (only "text/plain" ships enabled). Markdown
# isn't HTML either, so without this every "&"/quote in kid/journal data
# would get corrupted into "&amp;"/"&quot;" in the rendered output.
ActionView::Template::Handlers::ERB.escape_ignore_list += ['text/markdown']
