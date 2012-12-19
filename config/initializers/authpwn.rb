# Tweak the password expiration interval, or comment out the line to disable
# password expiration altogether.
#
# NOTE: when a user's password expires, he will need to use the password reset
# flow, which relies on e-mail delivery. If your application doesn't implement
# password reset, or doesn't have working e-mail delivery, disable password
# expiration.
Rails.application.config.authpwn.password_expiration = nil

# These codes are sent in plaintext in e-mails, be somewhat aggressive.
Rails.application.config.authpwn.email_verification_expiration = 3.days
Rails.application.config.authpwn.password_reset_expiration = 3.days

# Users are identified by cookies whose codes are looked up in the database.
Rails.application.config.authpwn.session_expiration = 14.days
# This knob is a compromise between accurate session expiration and write
# workload on the database. Keep it below 1% of expires_after.
Rails.application.config.authpwn.session_precision = 1.hour
