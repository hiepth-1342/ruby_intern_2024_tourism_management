class Tour < ApplicationRecord
  TOUR_ATTRIBUTES = %i(
    tour_name
    city
    tour_destination
    description
    price
    day_duration
    start_date
    end_date
    tour_type_id
    image
  ).freeze

  SEARCH_ATTRIBUTES = %i(
    name
    start_date
    min_duration
    max_duration
    min_price
    max_price
  ).freeze

  OPTION_ATTRIBUTES = %i(
    tour_type_id
    city
  ).freeze

  belongs_to :tour_type
  has_many :tour_flights, dependent: :destroy
  has_many :flights, through: :tour_flights
  has_many :bookings, dependent: :destroy
  has_many :reviews, dependent: :destroy

  validates :tour_name, presence: true,
                        length: {maximum: Settings.tour.max_len_name}
  validates :city, :tour_destination, :description, presence: true
  validates :day_duration, presence: true,
                       numericality: {only_integer: true,
                                      maximum: Settings.tour.max_duration}
  validates :start_date, :end_date, presence: true
  validate :end_date_after_start_date
  validate :start_date_after_today

  has_many_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: Settings.tour.limit_250_250
  end
  scope :upcoming, ->{order start_date: :asc}
  scope :by_name, lambda {|name|
    where("tour_name LIKE ?", "%#{sanitize_sql_like(name)}%") if name.present?
  }
  scope :by_min_duration, lambda {|min_duration|
    where("day_duration >= ?", min_duration.presence ||
    Settings.tour.search.min_duration)
  }
  scope :by_max_duration, lambda {|max_duration|
    where("day_duration <= ?", max_duration.presence ||
    Settings.tour.search.max_duration)
  }
  scope :by_city, lambda {|city|
    where("city LIKE ?", "%#{sanitize_sql_like(city)}%") if city.present?
  }
  scope :by_min_price, lambda {|min_price|
    where("price >= ?", min_price.presence ||
    Settings.tour.search.min_price)
  }
  scope :by_max_price, lambda {|max_price|
    where("price <= ?", max_price.presence ||
    Settings.tour.search.max_price)
  }
  scope :by_start_date, lambda {|start_date|
    where("start_date >= ?", start_date.presence ||
    Settings.tour.search.start_date)
  }
  scope :by_tour_type_id, lambda {|tour_type_id|
    where("tour_type_id = ?", tour_type_id) if tour_type_id.present?
  }

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    return unless end_date <= start_date

    errors.add(:end_date, I18n.t("errors.end_day_start_date"))
  end

  def start_date_after_today
    return if start_date.blank?

    return unless start_date <= Time.zone.today

    errors.add(:start_date, I18n.t("errors.start_date_today"))
  end
end
