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
    element :card_type, :class => CardTypeValue
    element :user, :class => UserValue
    element :card, :class => CardValue
    value :text
  end

  class Change
    include SAXMachine
    attribute :type
  end

  class CardCopyChange < Change
    element :source, :value => :url, :as => :source_url
    element :destination, :value => :url, :as => :destination_url
  end

  class NameChange < Change
    element :old_value
    element :new_value
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
  end

  class TagChange < Change
    element :tag
  end

  class AttachmentChange < Change
    element :url
    element :file_name
  end

  class CommentChange < Change
    element :comment
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