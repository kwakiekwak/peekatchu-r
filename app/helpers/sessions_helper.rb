module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    # We can treat session as if it were a hash
    # So we assign in (below)
    session[:user_id] = user.id
    # tried to get session[:challenge_id] to populate into posts
    # session[:challenge_id] = challenge.id
  end


  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent.signed[:remember_token] = user.remember_token
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
  # Returns the current logged-in user (if any).
    if (user_id = session[:user_id])
    # ||= means "or equals"
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.signed[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end
end


# ratyrate model.rb

# extend ActiveSupport::Concern

  def rate(stars, user, dimension=nil, dirichlet_method=false)
    dimension = nil if dimension.blank?

    if can_rate? user, dimension
      rates(dimension).create! do |r|
        r.stars = stars
        r.rater = user
      end
      if dirichlet_method
        update_rate_average_dirichlet(stars, dimension)
      else
        update_rate_average(stars, dimension)
      end
    else
      update_current_rate(stars, user, dimension)
    end
  end

  def update_rate_average_dirichlet(stars, dimension=nil)
    # assumes 5 possible vote categories
    dp = {1 => 1, 2 => 1, 3 => 1, 4 => 1, 5 => 1}
    stars_group = Hash[rates(dimension).group(:stars).count.map{|k,v| [k.to_i,v] }]
    posterior = dp.merge(stars_group){|key, a, b| a + b}
    sum = posterior.map{ |i, v| v }.inject { |a, b| a + b }
    davg = posterior.map{ |i, v| i * v }.inject { |a, b| a + b }.to_f / sum

    if average(dimension).nil?
      send("create_#{average_assoc_name(dimension)}!", { avg: davg, qty: 1, dimension: dimension })
    else
      a = average(dimension)
      a.qty = rates(dimension).count
      a.avg = davg
      a.save!(validate: false)
    end
  end

  def update_rate_average(stars, dimension=nil)
    if average(dimension).nil?
      send("create_#{average_assoc_name(dimension)}!", { avg: stars, qty: 1, dimension: dimension })
    else
      a = average(dimension)
      a.qty = rates(dimension).count
      a.avg = rates(dimension).average(:stars)
      a.save!(validate: false)
    end
  end

  def update_current_rate(stars, user, dimension)
    current_rate = rates(dimension).where(rater_id: user.id).take
    current_rate.stars = stars
    current_rate.save!(validate: false)

    if rates(dimension).count > 1
      update_rate_average(stars, dimension)
    else # Set the avarage to the exact number of stars
      a = average(dimension)
      a.avg = stars
      a.save!(validate: false)
    end
  end

  def overall_avg(user)
    # avg = OverallAverage.where(rateable_id: self.id)
    # #FIXME: Fix the bug when the movie has no ratings
    # unless avg.empty?
    #   return avg.take.avg unless avg.take.avg == 0
    # else # calculate average, and save it
    #   dimensions_count = overall_score = 0
    #   user.ratings_given.select('DISTINCT dimension').each do |d|
    #     dimensions_count = dimensions_count + 1
    #     unless average(d.dimension).nil?
    #       overall_score = overall_score + average(d.dimension).avg
    #     end
    #   end
    #   overall_avg = (overall_score / dimensions_count).to_f.round(1)
    #   AverageCache.create! do |a|
    #     a.rater_id = user.id
    #     a.rateable_id = self.id
    #     a.avg = overall_avg
    #   end
    #   overall_avg
    # end
  end

  # calculates the movie overall average rating for all users
  def calculate_overall_average
    rating = Rate.where(rateable: self).pluck('stars')
    (rating.reduce(:+).to_f / rating.size).round(1)
  end

  def average(dimension=nil)
    send(average_assoc_name(dimension))
  end

  def average_assoc_name(dimension = nil)
    dimension ? "#{dimension}_average" : 'rate_average_without_dimension'
  end

  def can_rate?(user, dimension=nil)
    rates(dimension).where(rater_id: user.id).size.zero?
  end

  def rates(dimension=nil)
    dimension ? self.send("#{dimension}_rates") : rates_without_dimension
  end

  def raters(dimension=nil)
    dimension ? self.send("#{dimension}_raters") : raters_without_dimension
  end

  def ratyrate_rater
    has_many :ratings_given, class_name: 'Rate', foreign_key: :rater_id
  end

  def ratyrate_rateable(*dimensions)
    has_many :rates_without_dimension, -> { where dimension: nil}, as: :rateable, class_name: 'Rate', dependent: :destroy
    has_many :raters_without_dimension, through: :rates_without_dimension, source: :rater

    has_one :rate_average_without_dimension, -> { where dimension: nil}, as: :cacheable,
            class_name: 'RatingCache', dependent: :destroy

    dimensions.each do |dimension|
      has_many "#{dimension}_rates".to_sym, -> {where dimension: dimension.to_s},
                                            dependent: :destroy,
                                            class_name: 'Rate',
                                            as: :rateable

      has_many "#{dimension}_raters".to_sym, through: :"#{dimension}_rates", source: :rater

      has_one "#{dimension}_average".to_sym, -> { where dimension: dimension.to_s },
                                            as: :cacheable,
                                            class_name: 'RatingCache',
                                              dependent: :destroy
      # end
    end
  end

# helper.rb

def rating_for(rateable_obj, dimension=nil, options={})

    cached_average = rateable_obj.average dimension
    avg = cached_average ? cached_average.avg : 0

    star         = options[:star]         || 5
    enable_half  = options[:enable_half]  || false
    half_show    = options[:half_show]    || true
    star_path    = options[:star_path]    || ''
    star_on      = options[:star_on]      || image_path('star-on.png')
    star_off     = options[:star_off]     || image_path('star-off.png')
    # star_half    = options[:star_half]    || image_path('star-half.png')
    cancel       = options[:cancel]       || false
    cancel_place = options[:cancel_place] || 'left'
    cancel_hint  = options[:cancel_hint]  || 'Cancel current rating!'
    cancel_on    = options[:cancel_on]    || image_path('cancel-on.png')
    cancel_off   = options[:cancel_off]   || image_path('cancel-off.png')
    # noRatedMsg   = options[:noRatedMsg]   || 'I\'am readOnly and I haven\'t rated yet!'
    # round        = options[:round]        || { down: .26, full: .6, up: .76 }
    space        = options[:space]        || false
    single       = options[:single]       || false
    target       = options[:target]       || ''
    targetText   = options[:targetText]   || ''
    targetType   = options[:targetType]   || 'hint'
    targetFormat = options[:targetFormat] || '{score}'
    targetScore  = options[:targetScore]  || ''
    readOnly     = options[:readonly]     || false

    disable_after_rate = options[:disable_after_rate] && true
    disable_after_rate = true if disable_after_rate == nil
  end

  #   unless readOnly
  #     if disable_after_rate
  #       readOnly = !(current_user && rateable_obj.can_rate?(current_user, dimension))
  #     else
  #       readOnly = !current_user || false
  #     end
  #   end

  #   if options[:imdb_avg] && readOnly
  #     content_tag :div, '', :style => "background-image:url('#{image_path('mid-star.png')}');width:61px;height:57px;margin-top:10px;" do
  #         content_tag :p, avg, :style => "position:relative;font-size:.8rem;text-align:center;line-height:60px;"
  #     end
  #   else
  #     content_tag :div, '', "data-dimension" => dimension, :class => "star", "data-rating" => avg,
  #                 "data-id" => rateable_obj.id, "data-classname" => rateable_obj.class.name == rateable_obj.class.base_class.name ? rateable_obj.class.name : rateable_obj.class.base_class.name,
  #                 "data-disable-after-rate" => disable_after_rate,
  #                 "data-readonly" => readOnly,
  #                 "data-enable-half" => enable_half,
  #                 "data-half-show" => half_show,
  #                 "data-star-count" => star,
  #                 "data-star-path" => star_path,
  #                 "data-star-on" => star_on,
  #                 "data-star-off" => star_off,
  #                 "data-star-half" => star_half,
  #                 "data-cancel" => cancel,
  #                 "data-cancel-place" => cancel_place,
  #                 "data-cancel-hint"  => cancel_hint,
  #                 "data-cancel-on" => cancel_on,
  #                 "data-cancel-off" => cancel_off,
  #                 "data-no-rated-message" => noRatedMsg,
  #                 # "data-round" => round,
  #                 "data-space" => space,
  #                 "data-single" => single,
  #                 "data-target" => target,
  #                 "data-target-text" => targetText,
  #                 "data-target-type" => targetType,
  #                 "data-target-format" => targetFormat,
  #                 "data-target-score" => targetScore
  #   # end
  # end

  def imdb_style_rating_for(rateable_obj, user, options = {})
    #TODO: add option to change the star icon
    overall_avg = rateable_obj.overall_avg(user)

    content_tag :div, '', :style => "background-image:url('#{image_path('big-star.png')}');width:70px;height:70px;margin-top:10px;" do
        content_tag :p, overall_avg, :style => "position:relative;line-height:85px;text-align:center;"
    end
  end

  def rating_for_user(rateable_obj, rating_user, dimension = nil, options = {})
    @object = rateable_obj
    @user   = rating_user
    @rating = Rate.find_by_rater_id_and_rateable_id_and_dimension(@user.id, @object.id, dimension)
    stars = @rating ? @rating.stars : 0

    star         = options[:star]         || 5
    # enable_half  = options[:enable_half]  || false
    # half_show    = options[:half_show]    || true
    star_path    = options[:star_path]    || ''
    star_on      = options[:star_on]      || image_path('star-on.png')
    star_off     = options[:star_off]     || image_path('star-off.png')
    star_half    = options[:star_half]    || image_path('star-half.png')
    cancel       = options[:cancel]       || false
    cancel_place = options[:cancel_place] || 'left'
    cancel_hint  = options[:cancel_hint]  || 'Cancel current rating!'
    cancel_on    = options[:cancel_on]    || image_path('cancel-on.png')
    cancel_off   = options[:cancel_off]   || image_path('cancel-off.png')
    noRatedMsg   = options[:noRatedMsg]   || 'I\'am readOnly and I haven\'t rated yet!'
    # round        = options[:round]        || { down: .26, full: .6, up: .76 }
    space        = options[:space]        || false
    single       = options[:single]       || false
    target       = options[:target]       || ''
    targetText   = options[:targetText]   || ''
    targetType   = options[:targetType]   || 'hint'
    targetFormat = options[:targetFormat] || '{score}'
    targetScore  = options[:targetScore]  || ''
    readOnly     = options[:readonly]     || false

    disable_after_rate = options[:disable_after_rate] || false

    if disable_after_rate
      readOnly = rating_user.present? ? !rateable_obj.can_rate?(rating_user, dimension) : true
    end

    content_tag :div, '', "data-dimension" => dimension, :class => "star", "data-rating" => stars,
                "data-id" => rateable_obj.id, "data-classname" => rateable_obj.class.name == rateable_obj.class.base_class.name ? rateable_obj.class.name : rateable_obj.class.base_class.name,
                "data-disable-after-rate" => disable_after_rate,
                "data-readonly" => readOnly,
                "data-enable-half" => enable_half,
                "data-half-show" => half_show,
                "data-star-count" => star,
                "data-star-path" => star_path,
                "data-star-on" => star_on,
                "data-star-off" => star_off,
                "data-star-half" => star_half,
                "data-cancel" => cancel,
                "data-cancel-place" => cancel_place,
                "data-cancel-hint"  => cancel_hint,
                "data-cancel-on" => cancel_on,
                "data-cancel-off" => cancel_off,
                "data-no-rated-message" => noRatedMsg,
                # "data-round" => round,
                "data-space" => space,
                "data-single" => single,
                "data-target" => target,
                "data-target-text" => targetText,
                "data-target-format" => targetFormat,
                "data-target-score" => targetScore
  end

class ActionView::Base
  include Helpers
end




