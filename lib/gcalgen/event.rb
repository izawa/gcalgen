require 'gcalapi'
require 'active_support/time'
require 'calendar/japanese/holiday'

require 'pry'

class Event
  attr_accessor :title, :start_time, :end_time, :desc, :main_method, :sub_method, :date, :location, :range_begins, :range_ends, :allday, :every
  attr_accessor :cal_name

  def initialize(title)
    @title = title
  end

####
## DSL functions
####

  def on(date)
    @date=DateTime.parse(date)
    @date = @date.change(:offset => DateTime.now.zone)
  end

  def starts(start_time)
    @start_time = start_time
  end

  def ends(end_time)
    @end_time = end_time
  end

  def at(location)
    @location = location
  end

  def desc(desc)
    @desc = desc
  end

  def all_day
    @allday = true
  end

  def every(method, &block)
    @every = Every.new(method)
    @every.instance_eval &block if block_given?
  end

  def range_begins(date)
    @range_begins = DateTime.parse(date)
    @range_begins = @range_begins.change(:offset => DateTime.now.zone)
  end

  def range_ends(date)
    @range_ends = DateTime.parse(date)
    @range_ends = @range_ends.change(:offset => DateTime.now.zone)
  end

  def calendar(cal_name)
    @cal_name = cal_name
  end


####
## internal methods
####

  def _check_holiday(date)
    d = date.to_date.extend Calendar::Japanese::Holiday
    d.holiday?
  end

  def _get_first(date, business_day)
    first = date.beginning_of_month
    if business_day
      while _check_holiday(first)
        first += 1.day
      end
    end
    first
  end

  def _get_last(date, business_day)
    last = date.end_of_month
    if business_day
      while _check_holiday(last)
        last -= 1.day
      end
    end
    last
  end

  def _generate_st_en(today)
    allday = true if @allday
    if @start_time =~/(\d\d):(\d\d)/
      st = today.to_time
      st += $1.to_i.hours
      st += $2.to_i.minutes
      if @end_time =~/(\d\d):(\d\d)/
        en = today.to_time
        en+= $1.to_i.hours
        en+= $2.to_i.minutes
      else
        en = st + 1.hour 
      end
    else
      st = today.in_time_zone
      en = today.in_time_zone
      allday = true
    end
    return {:st => st, :en => en, :allday => allday}
  end

  def _generate_weekly
    ret = []

    if @range_begins 
      today = @range_begins
    else
      today = Date.today 
      today = today.change(:offset => DateTime.now.zone)
    end
    if @range_ends
      limit = @range_ends
    else
      limit = today + 3.month
      limit = limit.change(:offset => DateTime.now.zone)
    end

    @every.weekday = today.strftime('%A') unless @every.weekday

    # search matched wday forward
    while today.strftime('%A') !~ /#{@every.weekday}/i
      today += 1.day
    end
    # generate array of st,en 
    while today < limit
      if _check_holiday(today)
        if @every.business
          if @every.shift
            while _check_holiday(today)
              today += 1.day
            end
          else
            today += 7.days
            next
          end
        end
      end
      ret << _generate_st_en(today)
      today = today.next_week
    end
    ret
  end

  def _generate_monthly
    ret = []

    if @range_begins 
      today = @range_begins
    else
      today = Date.today 
      today = today.change(:offset => DateTime.now.zone)
    end

    if @range_ends
      limit = @range_ends
    else
      limit = today + 6.month
      limit = limit.change(:offset => DateTime.now.zone)
    end

    # generate array of st/en
    while today < limit
      if @every.first_flg
        today = _get_first(today, @every.business_day)
      elsif @every.last_flg
        today = _get_last(today, @every.business_day)
      end
      today = today.beginning_of_day

      ## st time/ en time
      ##
      ret << _generate_st_en(today)
      today = today.next_month.beginning_of_month
    end
    ret
  end

  def _generate_annualy
    ret = []

    today = @date
    if @range_begins 
      while @range_begins > today
        today = today.next_year
      end
    end
    if @range_ends
      limit = @range_ends
    else
      limit = today + 5.years
      limit = limit.change(:offset => DateTime.now.zone)
    end

    # generate array of st/en
    while today < limit
      ## st time/ en time
      ##
      ret << _generate_st_en(today)
      today = today.next_year
    end
    ret
  end

  def _generate_oneshot
    ret = []
    if @start_time
      today = @date.beginning_of_day
      today = DateTime.parse(@date.strftime("%Y/%m/%d ") + @start_time + DateTime.now.zone)
      st = today
      if @end_time
        today = @date.beginning_of_day
        today = DateTime.parse(@date.strftime("%Y/%m/%d ") + @end_time + DateTime.now.zone)
        en=today
      else
        en = st + 1.hour
      end
    else
      st = @date.beginning_of_day
      en= @date.beginning_of_day
      allday = true
    end
    ret << {:st => st, :en => en, :allday => allday}
  end

  def generate_gcalevent
    ret = []

    if @cal_name
      user = $myConfig[@cal_name].cal_user
      password = $myConfig[@cal_name].cal_password
      feed = $myConfig[@cal_name].cal_feed
    else
      user = $myConfig['default'].cal_user
      password = $myConfig['default'].cal_password
      feed = $myConfig['default'].cal_feed
    end

    cal = GoogleCalendar::Calendar.new(GoogleCalendar::Service.new(user, password), feed)

    if @every
      if @every.method =~ /week/i
        st_en = _generate_weekly
      elsif @every.method =~ /month/i
        st_en = _generate_monthly
      elsif @every.method =~ /year/i
        st_en = _generate_annualy
      end
    else # one shot event
      st_en = _generate_oneshot
    end

    st_en.each {|val|
      event = cal.create_event
      event.title = @title
      event.desc  = @desc
      event.where = @location
      event.allday = val[:allday]
      event.st = val[:st]
      event.en = val[:en]
      ret << event
    }
    ret
  end
end
