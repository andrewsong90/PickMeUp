module ApplicationHelper
  # get the link for the google map
  def get_google_map_link(latitude, longitude)
    return "https://maps.google.com/maps?q=loc:#{latitude},#{longitude}"
  end

  # get the link for the google map's image
  def get_google_map_image_link(latitude, longitude)
    return "http://maps.google.com/maps/api/staticmap?size=450x300&sensor=false&zoom=16&markers=#{latitude}%2C#{longitude}"
  end

  # get the image url for the image. if the image is from filepicker, use filepicker method. else return the link directly
  def parse_image_tag(image_url)
    if image_url.include? "filepicker"
      return filepicker_image_tag image_url
    else
      return image_tag image_url
    end
  end
  
  # this is for flash message
  def bootstrap_class_for flash_type
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-error"
      when :alert
        "alert-block"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end
end
