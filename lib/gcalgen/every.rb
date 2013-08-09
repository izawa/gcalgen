class Every
  attr_accessor :method, :weekday, :mmdd, :first_flg, :last_flg, :shift, :business
  def initialize(method)
    @method = method
  end

  def wday(weekday)
    @weekday = weekday
  end

  def first
    @first_flg = true
  end

  def last
    @last_flg = true
  end

  def shift_enable
    @shift = true
  end

  def business_day
    @business = true
  end
end
