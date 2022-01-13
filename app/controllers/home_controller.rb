class HomeController < ApplicationController
  ICON_FILE_NAME = 'klc_favicon'

  def welcome
    render json: { hello: "world" }
  end

  def favicon_ico
    favicon('ico')
  end

  def favicon_png
    favicon('png')
  end

  def favicon(extension)
    send_file Rails.root.join("public", "#{ICON_FILE_NAME}.#{extension}"), type: "image/#{image_extension(extension)}", disposition: "inline"
  end

  def image_extension(ext)
    return 'jpg' unless ext
    ext.downcase == 'ico' ? 'x-icon' : ext
  end
end
