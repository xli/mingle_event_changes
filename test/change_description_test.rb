require File.dirname(__FILE__) + "/test_helper"

class ChangeDescriptionTest < Test::Unit::TestCase
  def test_simple_change_type_does_not_have_desc
    change = MingleEventChanges::Change.parse('<change type="card-creation"/>')
    assert_nil change.desc
  end

  def test_property_is_set_to_specific_value
    change = MingleEventChanges::PropertyChange.parse(<<-XML)
    <change type="property-change">
      <property_definition 
        url="http://your_mingle_server.com/api/v2/projects/your_project/property_definitions/10418.xml">
        <name>Priority</name>
        <position nil="true"></position>
        <data_type>string</data_type>
        <is_numeric type="boolean">false</is_numeric>
      </property_definition>
      <old_value nil="true"></old_value>
      <new_value>must</new_value>
    </change>
    XML
    assert_equal 'Priority: (not set) => must', change.desc
  end

  def test_property_updated
    change = MingleEventChanges::PropertyChange.parse(<<-XML)
    <change type="property-change">
      <property_definition 
        url="http://your_mingle_server.com/api/v2/projects/your_project/property_definitions/10418.xml">
        <name>Status</name>
        <position nil="true"></position>
        <data_type>string</data_type>
        <is_numeric type="boolean">false</is_numeric>
      </property_definition>
      <old_value>new</old_value>
      <new_value>closed</new_value>
    </change>
    XML
    assert_equal "Status: new => closed", change.desc
  end

  def test_set_property_value_to_nil
    change = MingleEventChanges::PropertyChange.parse(<<-XML)
    <change type="property-change">
      <property_definition 
        url="http://your_mingle_server.com/api/v2/projects/your_project/property_definitions/10418.xml">
        <name>Status</name>
        <position nil="true"></position>
        <data_type>string</data_type>
        <is_numeric type="boolean">false</is_numeric>
      </property_definition>
      <old_value>new</old_value>
      <new_value nil="true"/>
    </change>
    XML
    assert_equal "Status: new => (not set)", change.desc
  end

  def test_change_user_property
    change = MingleEventChanges::PropertyChange.parse(<<-XML)
    <change type="property-change">
      <property_definition url="https://mingle.mingle.thoughtworks.com/api/v2/projects/sanity/property_definitions/17486.xml">
        <name>Owner</name>
        <position nil="true"></position>
        <data_type>user</data_type>
        <is_numeric type="boolean">false</is_numeric>
      </property_definition>
      <old_value nil="true"></old_value>
      <new_value>
        <user url="https://mingle.mingle.thoughtworks.com/api/v2/users/10014.xml">
          <name>Tom</name>
          <login>tom</login>
        </user>
      </new_value>
    </change>
    XML
    assert_equal "Owner: (not set) => Tom", change.desc
  end

  def test_change_card_property
    change = MingleEventChanges::PropertyChange.parse(<<-XML)
    <change type="property-change">
      <property_definition url="https://mingle.mingle.thoughtworks.com/api/v2/projects/mingle_saas/property_definitions/10260.xml">
        <name>Iteration</name>
        <position type="integer">1</position>
        <data_type>card</data_type>
        <is_numeric type="boolean">false</is_numeric>
      </property_definition>
      <old_value nil="true"></old_value>
      <new_value>
        <card url="https://mingle.mingle.thoughtworks.com/api/v2/projects/mingle_saas/cards/406.xml">
          <number type="integer">406</number>
        </card>
      </new_value>
    </change>
    XML
    assert_equal "Iteration: (not set) => #406", change.desc
  end

  def test_card_type_change
    change = MingleEventChanges::CardTypeChange.parse(<<-XML)
    <change type="card-type-change">
      <old_value>
        <card_type url="http://your_mingle_server.com/api/v2/projects/your_project/card_types/123.xml">
          <name>Story</name>
        </card_type>
      </old_value>
      <new_value>
        <card_type url="http://your_mingle_server.com/api/v2/projects/your_project/card_types/432.xml">
          <name>Iteration</name>
        </card_type>
      </new_value>
    </change>
    XML
    assert_equal "Type: Story => Iteration", change.desc
  end

  def test_name_change
    change = MingleEventChanges::NameChange.parse(<<-XML)
    <change type="name-change">
      <old_value>Old name</old_value>
      <new_value>New name</new_value>
    </change>
    XML
    assert_equal "Name: \n  from: Old name\n  to: New name", change.desc
  end

  def test_set_name
    change = MingleEventChanges::NameChange.parse(<<-XML)
    <change type="name-change">
      <old_value nil="true"/>
      <new_value>New name</new_value>
    </change>
    XML
    assert_equal "Name: New name", change.desc
  end

  def test_comment_change
    change = MingleEventChanges::CommentChange.parse(<<-XML)
    <change type="comment-addition">
      <comment>Attached discussion from sales engineers.</comment>
    </change>
    XML
    assert_equal "Attached discussion from sales engineers.", change.desc
  end

  def test_attachment_change
    change = MingleEventChanges::AttachmentChange.parse(<<-XML)
    <change type="attachment-replacement">
      <attachment>
        <url>/attachments/b4a16f3dcbebe1cc631f8c5a08f78394/811/notes.txt</url>
        <file_name>notes.txt</file_name>
      </attachment>
    </change>
    XML
    assert_equal "attachment-replacement: notes.txt", change.desc
  end

  def test_tag_change
    change = MingleEventChanges::TagChange.parse(<<-XML)
    <change type="tag-addition">
      <tag>Client X</tag>
    </change>
    XML
    assert_equal "tag-addition: Client X", change.desc

    change = MingleEventChanges::TagChange.parse(<<-XML)
    <change type="tag-removal">
      <tag>Client Y</tag>
    </change>
    XML
    assert_equal "tag-removal: Client Y", change.desc
  end
end