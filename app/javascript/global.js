"use strict";

import Treeview from "treeview";
import Rails from "@rails/ujs";
// Registers Bootstrap's own data-bs-* auto-init listeners (navbar toggler,
// dropdowns) as a side effect of loading -- see the navbar markup in
// app/views/layouts/application.html.haml. Popovers have no such auto-init
// (see register_todotogglers below), so the module itself is imported too.
import bootstrap from "bootstrap";
import { register_theme_toggle } from "theme";

// A Bootstrap Icons sprite reference as an HTML string -- the JS twin of
// ApplicationHelper#icon (same markup, same .icon-svg sizing). The sprite's
// fingerprinted URL comes from the layout's <body data-icon-sprite>. Also
// imported by treeview.js (which this module imports in turn): that cycle is
// safe because this is a hoisted function declaration, only called after
// every module has loaded -- keep it one, not a const/arrow function.
export function iconMarkup(name) {
  var sprite = document.body.dataset.iconSprite;
  return '<svg class="icon-svg" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg" aria-hidden="true">' +
    '<use href="' + sprite + '#' + name + '"></use></svg>';
}

document.addEventListener('DOMContentLoaded', function() {
  register_theme_toggle();
  track_nav_height();
  register_journal_controls();
  register_mentor_journal_date_selectors();
  register_schedule_checkboxes();
  register_todotogglers();
  register_exit_at_toggler();
  register_freetext_toggler();
  register_treeview();
  register_document_search();
  register_autogrow_textareas();
  setTimeout(close_flash_alerts, 3000);
});


// Publishes the sticky navbar's rendered height as --nav-height, which the
// sticky sidebar offset and scroll-padding-top in application.scss use in
// place of the static $nav-height -- the nav grows when a long label (e.g.
// a kid's name) wraps to two lines, and would otherwise cover them.
function track_nav_height() {
  var nav = document.getElementById('nav');
  if (!nav || !window.ResizeObserver) return;
  new ResizeObserver(function() {
    document.documentElement.style.setProperty('--nav-height', nav.offsetHeight + 'px');
  }).observe(nav);
}

function register_journal_controls() {
  var cancelled = document.getElementById('journal_cancelled');
  if (!cancelled) return;
  cancelled.addEventListener('change', function() {
    var show_times = !this.checked;
    document.querySelectorAll('.journal_start_at, .journal_end_at').forEach(function(el) {
      el.style.display = show_times ? '' : 'none';
    });
  });
  cancelled.dispatchEvent(new Event('change'));
}

function register_mentor_journal_date_selectors() {
  document.querySelectorAll('select.select_mentor_journal_date').forEach(function(select) {
    select.addEventListener('change', function() {
      var month = encodeURIComponent(document.getElementById('date_month').value);
      var year = encodeURIComponent(document.getElementById('date_year').value);
      var href = window.location.pathname + '?month=' + month + '&year=' + year + '#mentor_journal_date';
      window.location = href;
    });
  });
}

function register_schedule_checkboxes() {
  document.querySelectorAll('form.schedule table input[type=checkbox]').forEach(function(checkbox) {
    var siblings = [...checkbox.parentElement.querySelectorAll('input')].filter(el => el !== checkbox);
    checkbox.addEventListener('change', function() {
      siblings.forEach(el => el.disabled = !this.checked);
    });
    siblings.forEach(el => el.disabled = !checkbox.checked);
  });
}

function register_todotogglers() {
  // The todo preview on kids/mentors/etc. index pages (data-bs-toggle=
  // "popover" on the .todotoggle links, see e.g. kids/index.html.haml) --
  // Bootstrap's own Popover component, Popper-positioned like any other
  // data-bs-* component, instead of a hand-rolled hover listener.
  document.querySelectorAll('[data-bs-toggle="popover"]').forEach(function(el) {
    new bootstrap.Popover(el);
  });
}

function register_exit_at_toggler() {
  var selects = document.querySelectorAll('#kid_exit_kind, #mentor_exit_kind');
  selects.forEach(function(select) {
    select.addEventListener('change', function() {
      var show = this.value === 'later';
      document.querySelectorAll('.kid_exit_at, .mentor_exit_at').forEach(function(el) {
        el.style.display = show ? '' : 'none';
      });
    });
  });
  selects.forEach(function(select) {
    select.dispatchEvent(new Event('change'));
  });
}

// grows a textarea to fit its content as the user types, so the full text
// stays visible instead of scrolling inside a fixed-height box
function register_autogrow_textareas() {
  document.querySelectorAll('textarea.form-control').forEach(function(textarea) {
    function resize() {
      textarea.style.height = 'auto';
      textarea.style.height = textarea.scrollHeight + 'px';
    }
    textarea.addEventListener('input', resize);
    resize();
  });
}

// Flash messages close themselves after a few seconds. Only those: other
// alerts (form error summaries, the document search's no-results hint)
// carry information that has to stay on screen.
function close_flash_alerts() {
  document.querySelectorAll('#flash .alert').forEach(function(el) {
    bootstrap.Alert.getOrCreateInstance(el).close();
  });
}

function register_freetext_toggler() {
  document.querySelectorAll('a.freetext').forEach(function(link) {
    link.addEventListener('click', function() {
      this.closest('.document_category').querySelectorAll('input, textarea, select, button').forEach(function(input) {
        var isHidden = input.style.display === 'none';
        input.style.display = isHidden ? '' : 'none';
        if (isHidden) {
          if (input.dataset.savedName !== undefined) {
            input.setAttribute('name', input.dataset.savedName);
          }
        } else {
          var currentName = input.getAttribute('name');
          if (currentName) input.dataset.savedName = currentName;
          input.removeAttribute('name');
        }
      });
    });
    link.click();
  });
}

var documentTree = null;

// Which folders of the documents tree are open, kept per browser across
// page loads (see Treeview's `expanded` path keys). Storage can be
// unavailable (private windows, blocked site data): then the tree simply
// starts with its first level open, as without saved state.
var DOCUMENT_TREE_STATE_KEY = 'documents.tree.expanded';

function loadDocumentTreeState() {
  try {
    var paths = JSON.parse(window.localStorage.getItem(DOCUMENT_TREE_STATE_KEY));
    return Array.isArray(paths) ? paths : null;
  } catch (e) {
    return null;
  }
}

function saveDocumentTreeState(paths) {
  try {
    window.localStorage.setItem(DOCUMENT_TREE_STATE_KEY, JSON.stringify(paths));
  } catch (e) {
    // not persisted -- the tree still works for this page view
  }
}

// The full (unfiltered) tree, opened as the user last left it. Search
// results are built separately, fully expanded and without saving, so a
// search never overwrites the saved state.
function buildDocumentTree(treeEl, data) {
  return new Treeview(treeEl, {
    data: data,
    enableLinks: true,
    levels: 1,
    expanded: loadDocumentTreeState(),
    onToggle: saveDocumentTreeState
  });
}

function register_treeview() {
  var treeEl = document.getElementById('tree');
  if (!treeEl) return;

  documentTree = buildDocumentTree(treeEl, JSON.parse(treeEl.dataset.tree));

  var expandAll = document.getElementById('tree_expand_all');
  if (expandAll) {
    expandAll.addEventListener('click', function() {
      documentTree.expandAll();
    });
  }

  var collapseAll = document.getElementById('tree_collapse_all');
  if (collapseAll) {
    collapseAll.addEventListener('click', function() {
      documentTree.collapseAll();
    });
  }

  var deleteNode = document.getElementById('tree_delete_node');
  if (deleteNode) {
    deleteNode.removeAttribute('data-method');
    deleteNode.removeAttribute('data-confirm');
    deleteNode.addEventListener('click', function(event) {
      event.preventDefault();
      event.stopPropagation();
      var nodes = documentTree.getSelected();
      if (nodes.length < 1) {
        alert('Bitte wählen Sie ein Dokument zum löschen.');
        return;
      }
      if (!window.confirm("Wirklich löschen?")) return;
      var nodeToRemove = nodes[0];
      var href = this.getAttribute('href') + '/' + nodeToRemove.documentId;
      Rails.ajax({
        type: 'DELETE',
        url: href,
        success: function() { location.reload(); },
        error: function(xhr) {
          console.error('Dokument konnte nicht gelöscht werden:', xhr.status, xhr.statusText);
          alert('Fehler beim Löschen des Dokuments (' + xhr.status + ').');
        }
      });
    });
  }

  var editNode = document.getElementById('tree_edit_node');
  if (editNode) {
    editNode.addEventListener('click', function(event) {
      event.preventDefault();
      event.stopPropagation();
      var nodes = documentTree.getSelected();
      if (nodes.length < 1) {
        alert('Bitte wählen Sie ein Dokument zum bearbeiten.');
        return;
      }
      window.location = this.getAttribute('href') + '/' + nodes[0].documentId + '/edit';
    });
  }

  treeEl.addEventListener('click', function(event) {
    var link = event.target.closest('a');
    if (!link) return;
    event.preventDefault();
    var href = link.getAttribute('href');
    if (href !== '#') window.open(href);
  });
}

function register_document_search() {
  var treeEl = document.getElementById('tree');
  var searchInput = document.getElementById('document_search');
  var clearButton = document.getElementById('document_search_clear');

  if (!searchInput || !treeEl) return;

  var originalTreeData = JSON.parse(treeEl.dataset.tree);
  if (!originalTreeData) return;

  if (clearButton) {
    clearButton.addEventListener('click', function() {
      searchInput.value = '';
      searchInput.dispatchEvent(new Event('input'));
    });
  }

  searchInput.addEventListener('input', function() {
    var searchTerm = this.value.toLowerCase().trim();
    var noResults = document.getElementById('search_no_results');

    if (clearButton) clearButton.style.display = searchTerm === '' ? 'none' : '';

    if (searchTerm === '') {
      if (noResults) noResults.style.display = 'none';
      treeEl.style.display = '';
      documentTree.remove();
      documentTree = buildDocumentTree(treeEl, originalTreeData);
    } else {
      var filteredData = filterTreeData(originalTreeData, searchTerm);
      documentTree.remove();

      if (filteredData.length === 0) {
        treeEl.style.display = 'none';
        if (noResults) noResults.style.display = '';
      } else {
        if (noResults) noResults.style.display = 'none';
        treeEl.style.display = '';
        documentTree = new Treeview(treeEl, {data: filteredData, enableLinks: true, levels: 10});
      }
    }
  });
}

function filterTreeData(nodes, searchTerm) {
  var filtered = [];

  nodes.forEach(function(node) {
    var isDocument = node.documentId !== undefined;
    var matchesTitle = isDocument && node.text && node.text.toLowerCase().includes(searchTerm);
    var filteredChildren = [];

    if (node.nodes && node.nodes.length > 0) {
      filteredChildren = filterTreeData(node.nodes, searchTerm);
    }

    if (matchesTitle || filteredChildren.length > 0) {
      var newNode = {
        text: node.text,
        selectable: node.selectable,
        icon: node.icon
      };

      if (isDocument) {
        newNode.href = node.href;
        newNode.documentId = node.documentId;
      }

      if (filteredChildren.length > 0) {
        newNode.nodes = filteredChildren;
      }

      filtered.push(newNode);
    }
  });

  return filtered;
}
