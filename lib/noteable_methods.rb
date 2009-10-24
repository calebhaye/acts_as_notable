require 'activerecord'

# ActsAsNoteable
module Juixe
  module Acts #:nodoc:
    module Noteable #:nodoc:

      def self.included(base)
        base.extend ClassMethods  
      end

      module ClassMethods
        def acts_as_noteable
          has_many :notes, :as => :noteable, :dependent => :destroy
          include Juixe::Acts::Noteable::InstanceMethods
          extend Juixe::Acts::Noteable::SingletonMethods
        end
      end
      
      # This module contains class methods
      module SingletonMethods
        # Helper method to lookup for notes for a given object.
        # This method is equivalent to obj.notes.
        def find_notes_for(obj)
          noteable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
         
          Note.find(:all,
            :conditions => ["noteable_id = ? and noteable_type = ?", obj.id, noteable],
            :order => "created_at DESC"
          )
        end
        
        # Helper class method to lookup notes for
        # the mixin noteable type written by a given user.  
        # This method is NOT equivalent to Note.find_notes_for_user
        def find_notes_by_user(user) 
          noteable = ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s
          
          Note.find(:all,
            :conditions => ["user_id = ? and noteable_type = ?", user.id, noteable],
            :order => "created_at DESC"
          )
        end
      end
      
      # This module contains instance methods
      module InstanceMethods
        # Helper method to sort notes by date
        def notes_ordered_by_submitted
          Note.find(:all,
            :conditions => ["noteable_id = ? and noteable_type = ?", id, self.class.name],
            :order => "created_at DESC"
          )
        end
        
        # Helper method that defaults the submitted time.
        def add_note(note)
          notes << note
        end
      end
      
    end
  end
end

ActiveRecord::Base.send(:include, Juixe::Acts::Noteable)
