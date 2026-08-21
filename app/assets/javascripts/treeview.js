// Minimal vanilla-JS re-implementation of the bootstrap-treeview jQuery
// plugin, covering only what global.js.erb actually uses: init with
// {data, enableLinks, levels}, expandAll, collapseAll, getSelected, remove.
// Markup/classes match vendor/assets/stylesheets/bootstrap-treeview.css so
// the visuals stay identical.
"use strict";

function Treeview(element, options) {
  this.element = element;
  this.options = options || {};
  this.nodes = [];
  this.tree = this.cloneData(this.options.data || []);
  this.element.classList.add('treeview');
  this.setInitialStates({ nodes: this.tree }, 0);
  this.element.addEventListener('click', this.handleClick.bind(this));
  this.render();
}

Treeview.prototype.cloneData = function(data) {
  return JSON.parse(JSON.stringify(data));
};

Treeview.prototype.setInitialStates = function(node, level) {
  if (!node.nodes) return;
  level += 1;

  var self = this;
  node.nodes.forEach(function(child) {
    child.nodeId = self.nodes.length;
    if (!child.hasOwnProperty('selectable')) child.selectable = true;
    child.state = child.state || {};
    if (!child.state.hasOwnProperty('selected')) child.state.selected = false;
    if (!child.state.hasOwnProperty('expanded')) {
      child.state.expanded = !!(child.nodes && child.nodes.length > 0 && level < (self.options.levels || 1));
    }
    self.nodes.push(child);
    if (child.nodes) self.setInitialStates(child, level);
  });
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

  if (event.target.classList.contains('expand-icon')) {
    node.state.expanded = !node.state.expanded;
    this.render();
  } else if (node.selectable) {
    this.selectOnly(node);
    this.render();
  } else {
    node.state.expanded = !node.state.expanded;
    this.render();
  }
};

Treeview.prototype.selectOnly = function(node) {
  this.nodes.forEach(function(n) { n.state.selected = false; });
  node.state.selected = true;
};

Treeview.prototype.expandAll = function() {
  this.nodes.forEach(function(n) { n.state.expanded = true; });
  this.render();
};

Treeview.prototype.collapseAll = function() {
  this.nodes.forEach(function(n) { n.state.expanded = false; });
  this.render();
};

Treeview.prototype.getSelected = function() {
  return this.nodes.filter(function(n) { return n.state.selected; });
};

Treeview.prototype.remove = function() {
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
    item.className = 'list-group-item';
    if (node.state.selected) item.classList.add('node-selected');
    item.setAttribute('data-nodeid', node.nodeId);
    if (node.state.selected) {
      item.style.color = '#FFFFFF';
      item.style.backgroundColor = '#428bca';
    }

    for (var i = 0; i < level - 1; i++) {
      var indent = document.createElement('span');
      indent.className = 'indent';
      item.appendChild(indent);
    }

    var expandIcon = document.createElement('span');
    expandIcon.className = 'icon';
    if (node.nodes) {
      expandIcon.classList.add('expand-icon', 'glyphicon');
      expandIcon.classList.add(node.state.expanded ? 'glyphicon-minus' : 'glyphicon-plus');
    } else {
      expandIcon.classList.add('glyphicon');
    }
    item.appendChild(expandIcon);

    if (node.icon) {
      var nodeIcon = document.createElement('span');
      nodeIcon.className = 'icon node-icon ' + node.icon;
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
