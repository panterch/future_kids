"use strict";

// Mirrors the resolution order of the inline no-flash script in
// application.html.haml's <head> (that one is duplicated as a plain string
// there since importmap modules aren't available that early). Pages that
// opt out via `content_for :force_light_theme` render without this menu
// and without the inline script, so this only ever runs on themeable pages.
export function register_theme_toggle() {
  var options = document.querySelectorAll('.theme-option');
  if (!options.length) return;

  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', function() {
    if (stored_theme()) return;
    apply_theme('auto');
  });

  options.forEach(function(option) {
    option.addEventListener('click', function() {
      var theme = option.getAttribute('data-theme-value');
      try {
        if (theme === 'auto') {
          localStorage.removeItem('theme');
        } else {
          localStorage.setItem('theme', theme);
        }
      } catch (e) {}
      apply_theme(theme);
    });
  });

  show_active_theme(stored_theme() || 'auto');
}

function stored_theme() {
  try { return localStorage.getItem('theme'); } catch (e) { return null; }
}

function apply_theme(theme) {
  var resolved = theme === 'auto'
    ? (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light')
    : theme;
  document.documentElement.setAttribute('data-bs-theme', resolved);
  show_active_theme(theme);
}

function show_active_theme(theme) {
  document.querySelectorAll('.theme-option').forEach(function(option) {
    var active = option.getAttribute('data-theme-value') === theme;
    option.classList.toggle('active', active);
    option.setAttribute('aria-pressed', active ? 'true' : 'false');
  });
}
