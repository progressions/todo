module Todo
  class << self
    def client
      user_profile = Cache.user_profile
      return client_from_username unless user_profile

      @client = Todoable::Client.new(
        token: user_profile["token"],
        expires_at: user_profile["expires_at"]
      )
      @client.authenticate!

      @client
    rescue Todoable::Unauthorized
      client_from_username
    end

    def client_from_username
      username = question("Enter username: ")
      password = question("Enter password: ", noecho: true)

      @client = Todoable::Client.new(
        username: username,
        password: password,
      )
      token, expires_at = @client.authenticate!

      Cache.save_user_profile(
        username: username,
        token: token,
        expires_at: expires_at,
      )

      @client
    end

  end
end
