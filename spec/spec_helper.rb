$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'rails'
require 'active_model'
require 'roadcrew'

Time.zone = 'Asia/Tokyo'

Dir[File.expand_path("../support/**/*.rb", __FILE__)].each { |f| require f }
