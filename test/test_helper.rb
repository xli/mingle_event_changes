$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "test/unit"
require "mingle_event_changes"

class Test::Unit::TestCase
  def fixtures(name)
    File.read(File.dirname(__FILE__) + "/fixtures/#{name}")
  end
end
