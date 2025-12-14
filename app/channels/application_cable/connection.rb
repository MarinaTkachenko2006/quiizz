module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user, :session_id
    
    def connect
      self.current_user = find_verified_user
      self.session_id = request.session.id
      logger.add_tags 'ActionCable', current_user&.nickname || 'Guest'
    end
    
    private
    
    def find_verified_user
      user_id = request.session[:user_id]
      
      if user_id
        User.find_by(id: user_id)
      else
        reject_unauthorized_connection
      end
    end
  end
end