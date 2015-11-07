################################################################################
#   pictures_processing.rb
#     Purpose: manages pictures to be uploaded / presented on the site
#
#   NB!  Picture entities MUST BE named as <Model>Picture
#
#   17.10.2014  ZT
#   18.10.2014  Update: absolute / relative paths
#   21.10.2014  Update: new upload approach
#   22.10.2014  picture_extension method added
#   17.05.2015  *resize_picture* update for different PATH constants
#   07.11.2015  New Gem
################################################################################
module ZtUp
  module PicturesProcessing
#    extend ActiveSupport::Concern

    require 'fileutils'   # needed to create a directory tree or to remove a folder with files

    ##############################################################################
    # Creates directory tree for a path to locate a picture files
    #
    # 'path' MUST BE absolute for 'mkdir'
    #
    # 21.10.2014  Update: new upload approach
    ##############################################################################
    def create_path path
      if path.include? 'public'         # path is absolute
         FileUtils.mkdir_p("#{path}")
      else                              # path is relative
        FileUtils.mkdir_p("#{PUBLIC_IMAGES_ROOT}/#{path}")
      end
    end

    ##############################################################################
    # Moves pictures to another Brand / City / Country / School
    #
    # File names to be with absolute path
    #
    # TBD
    ##############################################################################
    def move_picture picture
    end

    ##############################################################################
    # Unifies JPEG file extension to 'jpg'
    #
    # 22.10.2014  ZT
    ##############################################################################
    def picture_extension filename
      extension = filename.split('.').last.downcase
      extension = 'jpg' if extension == 'jpeg' || extension == 'jpg'
      extension
    end
    ##############################################################################
    # Removes directory with files uploaded for the picture
    #
    # FileUtils.remove_dir is applied with option 'true' to force removing
    #
    # File names to be with absolute path
    #
    # 21.10.2014  Update: new upload approach
    ##############################################################################
    def remove_picture picture
      path = "#{upload_path(picture)}/#{picture.id}"
      if path.include? 'public'           # path is absolute
         FileUtils.remove_dir path, true
      else                                # path is relative
        FileUtils.remove_dir "#{PUBLIC_IMAGES_ROOT}/#{path}", true
      end
    end

    ##############################################################################
    #  Resizes Picture via ImageMagick CLI proportionally:
    #     Width is given, height is automagically selected to preserve aspect ratio
    #
    #  Command format:
    #     convert <original_file> -resize <width> <destination_file>
    #
    #  No resizing for non-JPEG files (logo, etc)
    #  Arguments:
    #     picture_owner      - a Model which the picture belongs to
    #     path               - directory with files
    #     filename_extension - extension of the uploaded file
    #
    #  21.10.2014  Update: new uploading approach
    #  17.05.2015  different models - different picture widths
    ##############################################################################
    def resize_picture picture_owner, path, filename_extension

  #    if filename_extension == 'jpg'
        resize_factor = "PICTURE_#{picture_owner.upcase}_PREVIEW_SIZE".constantize.first    # e.g. *PICTURE_COACH_PREVIEW_SIZE*
        system "convert #{path}/original.#{filename_extension} -resize '#{resize_factor}' #{path}/preview.#{filename_extension}"

        resize_factor = "PICTURE_#{picture_owner.upcase}_VIEW_SIZE".constantize.first       # e.g. *PICTURE_COACH_VIEW_SIZE*
        system "convert #{path}/original.#{filename_extension} -resize '#{resize_factor}' #{path}/view.#{filename_extension}"
  #    else
  #      # for logo file: just symbol links to original one (nothing to resize)
  #      system "ln -s #{path}/original.#{filename_extension} #{path}/preview.#{filename_extension}"
  #      system "ln -s #{path}/original.#{filename_extension} #{path}/view.#{filename_extension}"
  #    end
      # Thumb is and in Africa thumb
      resize_factor = "PICTURE_#{picture_owner.upcase}_THUMB_SIZE".constantize.first        # e.g. *PICTURE_COACH_THUMB_SIZE*
      system "convert #{path}/original.#{filename_extension} -resize '#{resize_factor}' #{path}/thumb.#{filename_extension}"

    end

    ##############################################################################
    #  Uploads Picture and generates files of required sizes on a server
    #
    #  Arguments:
    #     picture - uploaded picture instance
    #
    #  21.10.2014  ZT
    #  16.05.2015  updated for 95km App
    ##############################################################################
    def upload_picture picture
      instance_class = picture.class.name                         # e.g. *CoachPicture*
      picture_owner  = instance_class.sub('Picture', '').upcase   # e.g. *COACH*

      # symbol is generated according to a model (e.g.  :room_picture)
      uploaded_io = params["#{instance_class.sub('Picture','_picture').downcase}".to_sym][:picture_name]

      # If file was uploaded
      unless uploaded_io.nil?
        original_filename  = uploaded_io.original_filename
        filename_extension = picture_extension original_filename

        path = "#{PUBLIC_IMAGES_ROOT}/#{upload_path(picture)}/#{picture.id}"

        # Generates Directory tree on a server for the picture
        create_path path

        # Generate original file size for uploaded picture on a server
        File.open("#{path}/original.#{filename_extension}", 'wb').write(uploaded_io.read)

        # Generate other sizes for uploaded picture  on a server
        resize_picture picture_owner, path, filename_extension
      end
    end

    ##############################################################################
    #  Defines upload_path CONSTANT for the given picture object, which could be:
    #    BrandPicture, CityPicture, CountryPicture, SchoolPicture
    #
    #  21.10.2014 ZT
    ##############################################################################
    def upload_path picture
      entity = picture.class.name.sub('Picture','').upcase
      "PICTURE_#{entity}_PATH".constantize
    end
  end
end