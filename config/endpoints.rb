Roadcrew.configure do
  garage admin: {
    endpoint: 'https://staart-admin.herokuapp.com',
    access_token: ENV['STAART_ADMIN_ACCESS_TOKEN']
  }
  garage analytics: {
    endpoint: 'https://staart-analytics.herokuapp.com',
    access_token: ENV['STAART_ANALYTICS_ACCESS_TOKEN']
  }
  garage scheduler: {
    endpoint: 'https://staart-scheduler.herokuapp.com',
    access_token: ENV['STAART_SCHEDULER_ACCESS_TOKEN']
  }
end
