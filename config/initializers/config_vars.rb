# Used in the scaffolded ConfigVarsController.
ConfigVars.string 'config_vars.http_user', 'config'
ConfigVars.string 'config_vars.http_password', 'vars'
ConfigVars.string 'config_vars.http_realm', 'Configuration Variables'

# Define your own configuration variables here.
ConfigVars.string 'app_uri' do
  if Rails.env.production?
    "http://#{Socket.gethostname}"
  else
    'http://localhost:3000'
  end
end
ConfigVars.string 'git_user', 'git'
ConfigVars.string('ssh_host') { Socket.gethostname }
ConfigVars.string('admin_email') { 'admin@' + Socket.gethostname }
ConfigVars.string 'markdpwn', 'enabled'
ConfigVars.string 'max_diff_lines', '10000'
ConfigVars.string 'signup.email_check', 'disabled'
