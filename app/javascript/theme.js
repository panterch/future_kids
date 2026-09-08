"use strict";

// Mirrors the resolution order of the inline no-flash script in
// application.html.haml's <head> (that one is duplicated as a plain string
// there since importmap modules aren't available that early). Pages that
// opt out via `content_for :force_light_theme` render without this button
// and without the inline script, so this only ever runs on themeable pages.
export function register_theme_toggle() {
  var button = document.getElementById('theme-toggle');
  if (!button) return;

  var media = window.matchMedia('(prefers-color-scheme: dark)');
  media.addEventListener('change', function(event) {
    if (stored_theme()) return;
    apply_theme(event.matches ? 'dark' : 'light');
  });

  button.addEventListener('click', function() {
    var current = document.documentElement.getAttribute('data-bs-theme');
    var next = current === 'dark' ? 'light' : 'dark';
    try { localStorage.setItem('theme', next); } catch (e) {}
    apply_theme(next);
  });
}

function stored_theme() {
  try { return localStorage.getItem('theme'); } catch (e) { return null; }
}

function apply_theme(theme) {
  document.documentElement.setAttribute('data-bs-theme', theme);
}
