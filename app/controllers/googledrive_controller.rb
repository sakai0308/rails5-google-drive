class GoogledriveController < ApplicationController
	def index
		client_id     = ENV["CLIENT_ID"]
		client_secret = ENV["CLIENT_SECRET"]
		refresh_token = ENV["REFRESH_TOKEN"]

		client = OAuth2::Client.new(
		    client_id,
		    client_secret,
		    site: "https://accounts.google.com",
		    token_url: "/o/oauth2/token",
		    authorize_url: "/o/oauth2/auth"
		)
		auth_token = OAuth2::AccessToken.from_hash(client,{:refresh_token => refresh_token, :expires_at => 3600})
		auth_token = auth_token.refresh!
		@session = GoogleDrive.login_with_oauth(auth_token.token)

		#session.files(q: "trashed = false and 'me' in owners") do |file|
		#session.files() do |file|
		#    owners = []
		#    file.owners.each do |owner|
		#        owners = "#{owner.display_name} <#{owner.email_address}>"
		#    end
		#
		#    puts "Debug: #{file.id} #{file.title} #{file.kind} #{owners}"
		#end
	end
end
