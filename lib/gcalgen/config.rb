
class GcalConfig
  attr_accessor :cal_name, :cal_feed, :cal_user, :cal_password

  def initialize(name)
    @cal_name = name
  end

####
## DSL functions
####

  def feed(feed)
    @cal_feed = feed
  end

  def user(user)
    @cal_user = user
  end

  def password(password)
    @cal_password = password
  end

end
