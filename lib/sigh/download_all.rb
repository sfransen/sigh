module Sigh
  class DownloadAll
    # Download all valid provisioning profiles
    def download_all
      UI.message "Starting login with user '#{Sigh.config[:username]}'"
      Spaceship.login(Sigh.config[:username], nil)
      Spaceship.select_team
      UI.message "Successfully logged in"

      Spaceship.provisioning_profile.all.each do |profile|
        if profile.valid?
          UI.message "Downloading profile '#{profile.name}'..."
          download_profile(profile)
        else
          UI.important "skip this Invalid Provison Profile invalid/expired profile '#{profile.name}'"
          ##profile.repair!
          ##download_profile(profile)
        end
      end
    end

    def download_profile(profile)
      FileUtils.mkdir_p(Sigh.config[:output_path])
      #profile_name = "#{profile.class.pretty_type}_#{profile.app.bundle_id}.mobileprovision" # default name

      # Push the changes back to the Apple Developer Portal
         if profile.class.pretty_type != "AppStore"
            profile.devices = Spaceship.device.all
            profile.update!
         end
      profile_name = "#{profile.name}.mobileprovision"
      goodname = profile_name.gsub(" ", "_")
      output_path = File.join(Sigh.config[:output_path], goodname)
      File.open(output_path, "wb") do |f|
        f.write(profile.download)
      end

      Manager.install_profile(output_path) unless Sigh.config[:skip_install]
    end
  end
end
