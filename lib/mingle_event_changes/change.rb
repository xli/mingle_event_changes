module MingleEventChanges
  class PropertyDefinition
    include SAXMachine
    element :name
    element :position
    element :data_type
    element :is_numeric
    attribute :url

    def is_numeric?
      is_numeric == 'true'
    end
  end

  class CardTypeValue
    include SAXMachine
    element :name
    attribute :url
  end

  class CardValue
    include SAXMachine
    element :number
    attribute :url
  end

  class UserValue
    include SAXMachine
    element :name
    element :login
    attribute :url
  end

  class Value
    include SAXMachine
    element :card_type, :as => :existing_card_type, :class => CardTypeValue
    element :user, :class => UserValue
    element :card, :class => CardValue
    element :deleted_card_type, :class => CardTypeValue
    value :text

    def card_type
      existing_card_type || deleted_card_type
    end
  end

  class Change
    include SAXMachine
    element :change, :value => :type, :as => :type

    # return a string description of the change
    # return nil for non-content change type, e.g. card-creation
    def desc
    end

    protected
    def display_value(value)
      case value
      when UserValue
        value.name
      when CardValue
        "##{value.number}"
      when CardTypeValue
        value.name
      else
        value
      end || '(not set)'
    end
  end

  class CardCopyChange < Change
    element :source, :value => :url, :as => :source_url
    element :destination, :value => :url, :as => :destination_url
  end

  class NameChange < Change
    element :old_value
    element :new_value

    def desc
      if old_value
        "Name: \n  from: #{old_value}\n  to: #{new_value}"
      else
        "Name: #{new_value}"
      end
    end
  end

  class PropertyChange < Change
    element :property_definition, :class => PropertyDefinition

    element :old_value, :as => :old_value_subject, :class => Value
    element :new_value, :as => :new_value_subject, :class => Value

    def old_value
      value(old_value_subject)
    end

    def new_value
      value(new_value_subject)
    end

    def desc
      "#{property_definition.name}: #{display_value(old_value)} => #{display_value(new_value)}"
    end

    private
    def value(subject)
      case property_definition.data_type
      when 'user'
        subject.user
      when 'card'
        subject.card
      else
        if r = subject.text
          r.empty? ? nil : r
        end
      end
    end
  end

  class CardTypeChange < Change
    element :old_value, :as => :old_value_subject, :class => Value
    element :new_value, :as => :new_value_subject, :class => Value

    def old_value
      old_value_subject.card_type
    end

    def new_value
      new_value_subject.card_type
    end

    def desc
      "Type: #{display_value(old_value)} => #{display_value(new_value)}"
    end
  end

  class TagChange < Change
    element :tag

    def desc
      "#{self.type}: #{tag}"
    end
  end

  class AttachmentChange < Change
    element :url
    element :file_name
    def desc
      "#{self.type}: #{file_name}"
    end
  end

  class CommentChange < Change
    element :comment

    def desc
      comment
    end
  end

  class Changes
    include SAXMachine
    TYPES = {
      'card-copied-to' => CardCopyChange,
      'card-copied-from' => CardCopyChange,
      'card-creation' => Change,
      'card-deletion' => Change,
      'card-type-change' => CardTypeChange,
      'description-change' => Change,
      'property-change' => PropertyChange,
      'name-change' => NameChange,
      'tag-addition' => TagChange,
      'tag-removal' => TagChange,
      'attachment-addition' => AttachmentChange,
      'attachment-removal' => AttachmentChange,
      'attachment-replacement' => AttachmentChange,
      'comment-addition' => CommentChange,
      'system-comment-addition' => CommentChange,
      'page-creation' => Change
    }.each do |type, clazz|
      elements :change, :as => "#{type.gsub(/-/, '_')}_changes", :class => clazz, :with => {:type => type}
    end

    def changes
      TYPES.keys.map do |k|
        send("#{k.gsub(/-/, '_')}_changes")
      end.flatten
    end
  end
end