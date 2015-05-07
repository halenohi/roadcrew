Roadcrew.configure do
  garage admin: {
    endpoint: 'https://staart-admin.herokuapp.com',
    access_token: ENV['STAART_ADMIN_ACCESS_TOKEN'],
    expires_at: ENV['STAART_ADMIN_EXPIRES_AT'],
    refresh_token: ENV['STAART_ADMIN_REFRESH_TOKEN']
  }
  garage analytics: {
    endpoint: 'https://staart-analytics.herokuapp.com',
    access_token: ENV['STAART_ANALYTICS_ACCESS_TOKEN'],
    expires_at: ENV['STAART_ADMIN_EXPIRES_AT'],
    refresh_token: ENV['STAART_ADMIN_REFRESH_TOKEN']
  }
  garage scheduler: {
    endpoint: 'https://staart-scheduler.herokuapp.com',
    access_token: ENV['STAART_SCHEDULER_ACCESS_TOKEN'],
    expires_at: ENV['STAART_ADMIN_EXPIRES_AT'],
    refresh_token: ENV['STAART_ADMIN_REFRESH_TOKEN']
  }
  garage twitter: {
    endpoint: 'https://staart-twitter.herokuapp.com',
    access_token: ENV['STAART_TWITTER_ACCESS_TOKEN']
  }
end
