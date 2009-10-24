module ActsAsNoteable
  # including this module into your Note model will give you finders and named scopes
  # useful for working with Notes.
  # The named scopes are:
  #   in_order: Returns notes in the order they were created (created_at ASC).
  #   recent: Returns notes by how recently they were created (created_at DESC).
  #   limit(N): Return no more than N notes.
  module Note
    
    def self.included(note_model)
      note_model.extend Finders
      note_model.named_scope :in_order, {:order => 'created_at ASC'}
      note_model.named_scope :recent, {:order => "created_at DESC"}
      note_model.named_scope :limit, lambda {|limit| {:limit => limit}}
    end
    
    module Finders
      # Helper class method to lookup all notes assigned
      # to all noteable types for a given user.
      def find_notes_by_user(user)
        find(:all,
          :conditions => ["user_id = ?", user.id],
          :order => "created_at DESC"
        )
      end

      # Helper class method to look up all notes for 
      # noteable class name and noteable id.
      def find_notes_for_noteable(noteable_str, noteable_id)
        find(:all,
          :conditions => ["noteable_type = ? and noteable_id = ?", noteable_str, noteable_id],
          :order => "created_at DESC"
        )
      end

      # Helper class method to look up a noteable object
      # given the noteable class name and id 
      def find_noteable(noteable_str, noteable_id)
        noteable_str.constantize.find(noteable_id)
      end
    end
  end
end