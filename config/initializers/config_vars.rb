# Definitions for configuration variables used in this application.

ConfigVars.string 'app_uri' do
  if Rails.env.production?
    "http://#{Socket.gethostname}"
  else
    'http://localhost:3000'
  end
end
ConfigVars.string 'git_user', 'git'
ConfigVars.string('ssh_host') { Socket.gethostname }
