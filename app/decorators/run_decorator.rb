class RunDecorator < Draper::Decorator
  delegate_all
  decorates_association :runner

  def duration_formatted
    h.format_duration(object.duration)
  end


  def interim_time_formatted(idx)
    time = object.interim_times[idx]
    if time
      h.format_duration(time)
    else
      '-'
    end
  end

  def alpha_foto_link
    if object.alpha_foto_url?
      h.link_to('Alphafoto', object.alpha_foto_url)
    end
  end
end
