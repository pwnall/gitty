# Tweak the password expiration interval, or comment out the line to disable
# password expiration altogether.
#
# NOTE: when a user's password expires, he will need to use the password reset
# flow, which relies on e-mail delivery. If your application doesn't implement
# password reset, or doesn't have working e-mail delivery, disable password
# expiration.
Credentials::Password.expires_after = nil

# These codes are sent in plaintext in e-mails, be somewhat aggressive.
Tokens::EmailVerification.expires_after = 3.days
Tokens::PasswordReset.expires_after = 3.days

# Users are identified by cookies whose codes are looked up in the database.
Tokens::SessionUid.expires_after = 14.days
# This knob is a compromise between accurate session expiration and write
# workload on the database. Keep it below 1% of expires_after.
Tokens::SessionUid.updates_after = 1.hour
