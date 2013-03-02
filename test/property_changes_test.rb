require File.dirname(__FILE__) + "/test_helper"

class PropertyChangesTest < Test::Unit::TestCase
  def setup
    @changes = MingleEventChanges.parse(fixtures('property_changes.xml'))
  end

  def test_card_data_type
    change = @changes.find(&data_type('card'))
    assert_equal nil, change.old_value
    assert_equal '406', change.new_value.number
    assert_equal 'https://mingle.mingle.thoughtworks.com/api/v2/projects/mingle_saas/cards/406.xml', change.new_value.url
  end

  def data_type(name)
    lambda {|c| c.property_definition.data_type == name}
  end
end