/**
 * @author Michał Bielawski <d3x@burek.it>
 * @name jQuery disable()
 * @license WTFPL (http://sam.zoy.org/wtfpl/)
 */
(function($) {
  $.fn.extend({
    disable: function() {
      return this.each(function() {
        $(this).attr({disabled: true});
      });
    },
    enable: function() {
      return this.each(function() {
        $(this).removeAttr('disabled');
      });
    },
    toggleDisabled: function(disable) {
      switch(typeof(disable)) {
        case "boolean": break;
        case "number": disable = disable > 0; break;
        default: disable = !this.is(':disabled');
      }
      return $(this)[disable ? "disable" : "enable"]();
    },
    toggleEnabled: function(enable) {
      switch(typeof(enable)) {
        case "boolean": break;
        case "number": enable = enable > 0; break;
        default: enable = this.is(':disabled');
      }
      return $(this)[enable ? "enable" : "disable"]();
    }
  });
})(jQuery);
