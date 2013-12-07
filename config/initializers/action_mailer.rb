unless Rails.env.test?
  Rails.application.config.action_mailer.delivery_method = :smtp
end

Rails.application.config.action_mailer.smtp_settings = {
  :address => "outgoing.mit.edu",
  :port => 25,
  :domain => "mit.edu",
}
