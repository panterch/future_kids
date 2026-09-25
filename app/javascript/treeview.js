// Minimal vanilla-JS re-implementation of the bootstrap-treeview jQuery
// plugin, covering only what global.js (the documents page) uses: init with
// {data, enableLinks, levels, expanded, onToggle}, expandAll, collapseAll,
// getSelected, remove.
//
// Folders are identified across page loads by their path of node texts
// (e.g. ["Anleitungen", "Mentoring"]) -- nodeId is only a position in this
// render and shifts whenever a category is added. `expanded` takes such
// path keys (see expandedPaths) and overrides `levels`; `onToggle` is called
// with the current ones after every expand/collapse.
// Renders a Bootstrap 5 list-group, styled by the .treeview rules in
// application.scss.
"use strict";

import { iconMarkup } from "global";

function Treeview(element, options) {
  this.element = element;
  this.options = options || {};
  this.nodes = [];
  this.tree = this.cloneData(this.options.data || []);
  this.element.classList.add('treeview');
  this.setInitialStates({ nodes: this.tree }, 0);
  this.boundHandleClick = this.handleClick.bind(this);
  this.element.addEventListener('click', this.boundHandleClick);
  this.render();
}

Treeview.prototype.cloneData = function(data) {
  return JSON.parse(JSON.stringify(data));
};

Treeview.prototype.setInitialStates = function(node, level, parentPath) {
  if (!node.nodes) return;
  level += 1;
  parentPath = parentPath || [];

  var self = this;
  var expanded = this.options.expanded;
  node.nodes.forEach(function(child) {
    var path = parentPath.concat(child.text);
    var hasChildren = !!(child.nodes && child.nodes.length > 0);
    child.nodeId = self.nodes.length;
    child.pathKey = JSON.stringify(path);
    if (!child.hasOwnProperty('selectable')) child.selectable = true;
    child.state = child.state || {};
    if (!child.state.hasOwnProperty('selected')) child.state.selected = false;
    if (!child.state.hasOwnProperty('expanded')) {
      child.state.expanded = hasChildren &&
        (expanded ? expanded.indexOf(child.pathKey) !== -1 : level < (self.options.levels || 1));
    }
    self.nodes.push(child);
    if (child.nodes) self.setInitialStates(child, level, path);
  });
};

// Path keys of the expanded folders, the format `expanded` takes.
Treeview.prototype.expandedPaths = function() {
  return this.nodes
    .filter(function(n) { return n.nodes && n.state.expanded; })
    .map(function(n) { return n.pathKey; });
};

Treeview.prototype.toggled = function() {
  this.render();
  if (this.options.onToggle) this.options.onToggle(this.expandedPaths());
};

Treeview.prototype.findNodeFromEvent = function(event) {
  var li = event.target.closest('li.list-group-item');
  if (!li) return null;
  return this.nodes[parseInt(li.getAttribute('data-nodeid'), 10)];
};

Treeview.prototype.handleClick = function(event) {
  if (!this.options.enableLinks) event.preventDefault();

  var node = this.findNodeFromEvent(event);
  if (!node) return;

  // closest(): the click lands on the icon's <svg>/<use>, not the span
  if (event.target.closest('.expand-icon') || !node.selectable) {
    node.state.expanded = !node.state.expanded;
    this.toggled();
  } else {
    this.selectOnly(node);
    this.render();
  }
};

Treeview.prototype.selectOnly = function(node) {
  this.nodes.forEach(function(n) { n.state.selected = false; });
  node.state.selected = true;
};

Treeview.prototype.expandAll = function() {
  this.nodes.forEach(function(n) { n.state.expanded = true; });
  this.toggled();
};

Treeview.prototype.collapseAll = function() {
  this.nodes.forEach(function(n) { n.state.expanded = false; });
  this.toggled();
};

Treeview.prototype.getSelected = function() {
  return this.nodes.filter(function(n) { return n.state.selected; });
};

Treeview.prototype.remove = function() {
  this.element.removeEventListener('click', this.boundHandleClick);
  this.element.innerHTML = '';
  this.nodes = [];
  this.tree = [];
};

Treeview.prototype.render = function() {
  this.element.innerHTML = '';
  var list = document.createElement('ul');
  list.className = 'list-group';
  this.buildTree(list, this.tree, 0);
  this.element.appendChild(list);
};

Treeview.prototype.buildTree = function(list, nodes, level) {
  if (!nodes) return;
  level += 1;

  var self = this;
  nodes.forEach(function(node) {
    var item = document.createElement('li');
    item.className = 'list-group-item list-group-item-action';
    item.setAttribute('data-nodeid', node.nodeId);
    if (node.state.selected) {
      item.classList.add('active');
      item.setAttribute('aria-current', 'true');
    }

    for (var i = 0; i < level - 1; i++) {
      var indent = document.createElement('span');
      indent.className = 'indent';
      item.appendChild(indent);
    }

    var expandIcon = document.createElement('span');
    expandIcon.className = 'icon';
    if (node.nodes) {
      expandIcon.classList.add('expand-icon');
      expandIcon.innerHTML = iconMarkup(node.state.expanded ? 'dash-lg' : 'plus-lg');
    }
    item.appendChild(expandIcon);

    if (node.icon) {
      var nodeIcon = document.createElement('span');
      nodeIcon.className = 'icon node-icon';
      nodeIcon.innerHTML = iconMarkup(node.icon);
      item.appendChild(nodeIcon);
    }

    if (self.options.enableLinks && node.href) {
      var link = document.createElement('a');
      link.href = node.href;
      link.style.color = 'inherit';
      link.textContent = node.text;
      item.appendChild(link);
    } else {
      item.appendChild(document.createTextNode(node.text));
    }

    list.appendChild(item);

    if (node.nodes && node.state.expanded) {
      self.buildTree(list, node.nodes, level);
    }
  });
};

export default Treeview;
