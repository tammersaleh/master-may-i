class Note < ActiveRecord::Base
  records_creating_user :as => "user"

  def self.listable_by(user)
    if user
      scoped({})
    else
      scoped({:conditions => ["? = ?", 1, 0]})
    end
  end

  def self.creatable_by?(user)
    user and user.username == "sue-create"
  end

  def readable_by?(user)
    user and user.username == "sue-read"
  end

  def editable_by?(user)
    user and user.username == "sue-edit"
  end

  def destroyable_by?(user)
    user and user.username == "sue-destroy"
  end
end
