
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
require "test/unit"
require "mingle_event_changes"

class ChangesTest < Test::Unit::TestCase
  def setup
    @changes = MingleEventChanges.parse(changes_xml).sort_by(&:type)
  end

  def test_parse_copy_from
    copy_from = @changes.find(&type('card-copied-from'))
    assert_equal 'card-copied-from', copy_from.type
    assert_equal 'http://your.mingle.server:8080/api/v2/projects/one/cards/2.xml', copy_from.source_url
    assert_equal 'http://your.mingle.server:8080/api/v2/projects/two/cards/3.xml', copy_from.destination_url
  end

  def test_parse_coped_to
    coped_to = @changes.find(&type('card-copied-to'))
    assert_equal 'card-copied-to', coped_to.type
    assert_equal 'http://your.mingle.server:8080/api/v2/projects/one/cards/2.xml', coped_to.source_url
    assert_equal 'http://your.mingle.server:8080/api/v2/projects/two/cards/3.xml', coped_to.destination_url
  end

  def test_parse_card_creation
    change = @changes.find(&type('card-creation'))
    assert_equal MingleEventChanges::Change, change.class
  end

  def test_parse_card_deletion
    change = @changes.find(&type('card-deletion'))
    assert_equal MingleEventChanges::Change, change.class
  end

  def test_card_type_change
    change = @changes.find(&type('card-type-change'))
    assert_equal 'Story', change.old_value.name
    assert_equal 'Iteration', change.new_value.name

    assert_equal 'http://your_mingle_server.com/api/v2/projects/your_project/card_types/123.xml', change.old_value.url
    assert_equal 'http://your_mingle_server.com/api/v2/projects/your_project/card_types/432.xml', change.new_value.url
  end

  def test_parse_description_change
    change = @changes.find(&type('description-change'))
    assert_equal MingleEventChanges::Change, change.class
  end

  def test_parse_name_change
    change = @changes.find(&type('name-change'))
    assert_equal 'Old name', change.old_value
    assert_equal 'New name', change.new_value
  end

  def test_parse_property_change
    change = @changes.find(&type('property-change'))
    assert_equal 'Priority', change.property_definition.name
    assert_equal 'http://your_mingle_server.com/api/v2/projects/your_project/property_definitions/10418.xml', change.property_definition.url
    assert_equal 'string', change.property_definition.data_type
    assert_equal 'false', change.property_definition.is_numeric
    assert_equal false, change.property_definition.is_numeric?
    assert_equal nil, change.old_value
    assert_equal 'must', change.new_value
  end

  def test_parse_tag_addition
    change = @changes.find(&type('tag-addition'))
    assert_equal 'Client X', change.tag
  end

  def test_parse_tag_removal
    change = @changes.find(&type('tag-removal'))
    assert_equal 'Needs review', change.tag
  end

  def test_parse_attachment_addition
    change = @changes.find(&type('attachment-addition'))
    assert_equal '/attachments/b4a16f3dcbebe1cc631f8c5a08f78394/811/notes.txt', change.url
    assert_equal 'notes.txt', change.file_name
  end

  def test_parse_attachment_removal
    change = @changes.find(&type('attachment-removal'))
    assert_equal '/attachments/b4a16f3dcbebe1cc631f8c5a08f78394/811/notes.txt', change.url
    assert_equal 'notes.txt', change.file_name
  end

  def test_parse_attachment_replacement
    change = @changes.find(&type('attachment-replacement'))
    assert_equal '/attachments/b4a16f3dcbebe1cc631f8c5a08f78394/811/notes.txt', change.url
    assert_equal 'notes.txt', change.file_name
  end

  def test_parse_comment_addition
    change = @changes.find(&type('comment-addition'))
    assert_equal 'Attached discussion from sales engineers.', change.comment
  end

  def test_parse_system_comment_addition
    change = @changes.find(&type('system-comment-addition'))
    assert_equal ' next release changed from release + 1 to release + 8 ', change.comment
  end

  def test_parse_system_comment_addition
    change = @changes.find(&type('page-creation'))
    assert_equal MingleEventChanges::Change, change.class
  end

  def type(name)
    lambda {|c| c.type == name}
  end

  def changes_xml
    File.read(File.dirname(__FILE__) + '/changes.xml')
  end
end