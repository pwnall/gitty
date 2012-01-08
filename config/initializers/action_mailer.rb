unless Rails.env.test?
  Gitty::Application.config.action_mailer.delivery_method = :smtp
end

Gitty::Application.config.action_mailer.smtp_settings = {
  :address => "outgoing.mit.edu",
  :port => 25,
  :domain => "mit.edu",
}
