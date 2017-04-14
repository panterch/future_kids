# Chromedriver has this annoying bug where when trying to click a button or
# something which is obscured by another element due to scrolling, it fails to
# click the button or link.
#
# This is a workaround to always scroll the element into view after finding it.
module Capybara
  module Chrome
    module Finders
      def find(*args)
        super(*args).tap do |node|
          if Capybara::Selenium::Driver === (driver = Capybara.current_session.driver)
            if (browser = driver.browser).browser.to_s =~ /chrome/
              browser.execute_script('arguments[0].scrollIntoView(false);', node.native)
            end
          end
        end
      end
    end
  end
end

Capybara::Node::Base.send :include, Capybara::Chrome::Finders
