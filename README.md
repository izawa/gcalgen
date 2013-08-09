# Gcalgen

Google calendar event generator

## Installation

Add this line to your application's Gemfile:

    gem install gcalgen

and create ~/.gcalgenrc


## .gcalgenrc

   def_calendar "default" do  # <-- "default" entry is required
   		feed  'http://www.google.com/calendar/feeds/XXXXXXXXXXXXXXXXXXXX@group.calendar.google.com/private/full'
		user  'XXXXXXXXXXXXX@gmail.com'
		password  'XXXXXXXXXXXXX'
   end

   def_calendar "another calendar" do
   		feed  'http://www.google.com/calendar/feeds/XXXXXXXXXXXXXXXXXXXX@group.calendar.google.com/private/full'
		user  'XXXXXXXXXXXXX@gmail.com'
		password  'XXXXXXXXXXXXX'
   end

   
## Usage

    % gcalgen eventfile1 [eventfile2....]


## Event file syntax

   ref, https://github.com/izawa/gcalgen/tree/master/examples

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
