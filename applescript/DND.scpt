# Script created for use with Patrick Wardle's Do Not Disturb application
# https://objective-see.com/products/dnd.html

# This script sends out an email from the default account in Mail.app
# It waits 3 minutes to capture all monitor logs before attaching the log to your email
# This allows you to review what the attacker might be doing remotely

# Make sure to turn on Monitor under Action > Monitor in Do Not Disturb preferences

# Fill out variables and add script path to Action > Execute Action in Do Not Disturb preferences
# Ex: osascript /Users/username/scripts/DND.scpt

# Set variables
set recipientName to "Recipient Name"
set recipientEmail to "RecipientEmail@abc.com"
set theSubject to "Do Not Disturb Alert"
set theContent to "Someone is messing with your bits!"
set theAttachmentFile to "Macintosh HD:Library:Objective-See:DND:DND.log"

tell application "Mail"
	# Create the message
	set theMessage to make new outgoing message with properties {subject:theSubject, content:theContent, visible:true}
	# Set a recipient
	tell theMessage
		make new to recipient with properties {name:recipientName, address:recipientEmail}
    # Wait 3 minutes to allow DND.log to populate
		delay 180
    # Attach DND.log
		make new attachment with properties {file name:theAttachmentFile as alias}
	end tell
	delay 3
  # Send the message
	send theMessage
end tell
