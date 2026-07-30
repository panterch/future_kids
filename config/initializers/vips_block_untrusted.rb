# Mitigation for CVE-2026-66066: prevent libvips from executing unsafe
# operations (e.g. arbitrary file read/RCE) when processing untrusted
# uploads (User#photo, Site#logo) via Active Storage variants.
Vips.block_untrusted(true) if defined?(Vips) && Vips.respond_to?(:block_untrusted)
