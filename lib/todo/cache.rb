require "redis"

module Todo
  class << self
    def cache
      Cache::Redis
      Cache::FileSystem
    end
  end

  module Cache
    module Redis
      class << self
        def lists
          JSON.parse(redis.get("lists"))
        rescue StandardError
          nil
        end

        def save_lists(lists)
          redis.set("lists", lists.to_json)
        end

        def user_profile
          user_json = redis.get("user_profile")
          JSON.parse(user_json)
        rescue StandardError
          nil
        end

        def save_user_profile(username:, token:, expires_at:)
          user_profile = {
            username: username,
            token: token,
            expires_at: expires_at,
          }

          redis.set("user_profile", user_profile.to_json)
        end

        def clear
          redis.set("user_profile", nil)
          redis.set("lists", nil)
        end

        private

        def redis
          @redis ||= ::Redis.new
        end
      end
    end

    module FileSystem
      class << self
        def lists
          verify_cache

          JSON.parse(File.read(lists_path))
        rescue StandardError
          nil
        end

        def save_lists(lists)
          verify_cache

          File.write(lists_path, lists.to_json)
        end

        def user_profile
          verify_cache

          user_json = File.read(user_profile_path)
          JSON.parse(user_json) if user_json
        rescue StandardError
          nil
        end

        def save_user_profile(username:, token:, expires_at:)
          verify_cache

          user_profile = {
            username: username,
            token: token,
            expires_at: expires_at,
          }

          File.open(user_profile_path, "w") do |f|
            f.write(user_profile.to_json)
          end
        end

        def clear
          FileUtils.rm_rf(todo_dir)
        end

        private

        def verify_cache
          Dir.mkdir(todo_dir) unless File.exists?(todo_dir)
        end

        def todo_dir
          @todo_dir ||= File.join(Dir.home, ".todo")
        end

        def user_profile_path
          File.join(todo_dir, "user")
        end

        def lists_path
          File.join(todo_dir, "lists")
        end
      end
    end
  end
end
