
require 'sax-machine'
require 'mingle_event_changes/change'

module MingleEventChanges
  module_function
  def parse(xml)
    Changes.parse(xml).changes
  end
end