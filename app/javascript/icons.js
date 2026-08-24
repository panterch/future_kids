// Inline SVG replacements for the glyphicon-* icon font (removed together
// with its vendored font files).
"use strict";

const PATHS = {
  eyeOpen: '<path d="M1 8s2.6-5 7-5 7 5 7 5-2.6 5-7 5-7-5-7-5z" fill="none" stroke="currentColor" stroke-width="1.3"/>' +
           '<circle cx="8" cy="8" r="2.2" fill="currentColor"/>',
  plus: '<rect x="7.2" y="2" width="1.6" height="12" fill="currentColor"/>' +
        '<rect x="2" y="7.2" width="12" height="1.6" fill="currentColor"/>',
  minus: '<rect x="2" y="7.2" width="12" height="1.6" fill="currentColor"/>',
  calendar: '<rect x="1.5" y="3" width="13" height="11.5" rx="1" fill="none" stroke="currentColor" stroke-width="1.3"/>' +
            '<line x1="1.5" y1="6.5" x2="14.5" y2="6.5" stroke="currentColor" stroke-width="1.3"/>' +
            '<line x1="4.5" y1="1.5" x2="4.5" y2="4.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/>' +
            '<line x1="11.5" y1="1.5" x2="11.5" y2="4.5" stroke="currentColor" stroke-width="1.3" stroke-linecap="round"/>',
  book: '<path d="M1.5 3.2c1.8-.9 3.8-.9 5.5 0v9.6c-1.7-.9-3.7-.9-5.5 0v-9.6z" fill="none" ' +
        'stroke="currentColor" stroke-width="1.1" stroke-linejoin="round"/>' +
        '<path d="M14.5 3.2c-1.8-.9-3.8-.9-5.5 0v9.6c1.7-.9 3.7-.9 5.5 0v-9.6z" fill="none" ' +
        'stroke="currentColor" stroke-width="1.1" stroke-linejoin="round"/>'
};

export function iconMarkup(name) {
  return '<svg class="icon-svg" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">' +
    PATHS[name] + '</svg>';
}
