class Admin::ToursController < Admin::AdminController
  include Admin::ToursHelper
  before_action :set_tour, only: %i(show edit update destroy remove_image)
  before_action :set_uploaded_images, only: %i(create update resize_before_save)
  before_action :resize_before_save, only: %i(create update)

  def index
    @pagy, @tours = pagy(Tour.upcoming,
                         items: Settings.tour.items_per_page)
  end

  def show; end

  def new
    @tour = Tour.new
  end

  def create
    @tour = Tour.new(tour_params)
    if @tour.save && check_image_limits(@tour, @uploaded_images)
      @tour.images.attach(@uploaded_images) if @uploaded_images.present?
      flash[:success] = t "flash.tour.create_success"
      redirect_to admin_tours_path, status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @tour.update(tour_params) && check_image_limits(@tour, @uploaded_images)
      @tour.images.attach(@uploaded_images) if @uploaded_images.present?
      flash[:success] = t "flash.tour.update_success"
      redirect_to admin_tours_path, status: :see_other
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    if @tour.destroy
      flash[:success] = t "flash.tour.delete_success"
    else
      flash[:danger] = t "flash.tour.delete_failure"
    end
    redirect_to admin_tours_path
  end

  def remove_image
    image = @tour.images.find(params[:image_id])
    image.purge
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.remove("image_#{params[:image_id]}")
      end
    end
  end

  def check_image_limits record, images
    if total_image_count_exceeds_limit?(record.images.count, images,
                                        Settings.images_limit)
      @tour.errors.add(:images, I18n.t("errors.images_limit",
                                       limit: Settings.images_limit))
      return false
    end
    true
  end

  private

  def set_tour
    @tour = Tour.find(params[:id])
    return if @tour

    redirect_to admin_tours_path, status: :see_other
    flash[:danger] = t "flash.tour.not_exist"
  end

  def set_uploaded_images
    @uploaded_images = filter_uploaded_images(params.dig(:tour, :images))
  end

  def tour_params
    params.require(:tour).permit Tour::TOUR_ATTRIBUTES
  end

  def resize_before_save
    return unless @uploaded_images

    @uploaded_images.each do |image|
      resize_image(image, Settings.width_img_250, Settings.heigt_img_250)
    end
  end

  def resize_image image_param, width, height
    return unless image_param

    begin
      image = MiniMagick::Image.read(image_param)
      image.resize "#{width}x#{height}"
      image.write(image_param.tempfile.path)
    rescue StandardError => _e
      # it's means the => file type is incorrect => model validations.
    end
  end
end
