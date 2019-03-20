module MasklistImporter
  @queue = :management

  def self.perform()
    sleep(rand(10))
    require_relative '../models/master'
    # Setup Logger
    logger_masklistimporter = Logger.new('logs/jobs/masklistImporter.log', 'daily')
    if ENV['RACK_ENV'] == 'development'
      logger_masklistimporter.level = Logger::DEBUG
    else
      logger_masklistimporter.level = Logger::INFO
    end

    logger_masklistimporter.debug('Masklist Importer Class() - has started')

    # Identify all masks in directory
    @files = Dir.glob(File.join('control/masks/', '*'))
    @files.each do |path_file|
      mask_entry = Masks.first(path: path_file)
      unless mask_entry
        # Get Name
        name = path_file.split('/')[-1]

        # Make sure we're not dealing with a tar, gz, tgz, etc. Not 100% accurate!
        unless name.match(/\.tar|\.7z|\.gz|\.tgz|\.checksum/)
          logger_masklistimporter.info('Importing new masklist "' + name + '" into HashView.')

          # Adding to DB
          mask = Masks.new
          mask.lastupdated = Time.now
          mask.name = name
          mask.path = path_file
          mask.size = 0
          mask.save
        end
      end
    end

    @files = Dir.glob(File.join('control/masks/', '*'))
    @files.each do |path_file|
      # Get Name
      name = path_file.split('/')[-1]
      unless name.match(/\.tar|\.7z|\.gz|\.tgz|\.checksum/)
        mask = Masks.first(path: path_file)
        if mask.size == '0'
          size = File.foreach(path_file).inject(0) do |c|
            c + 1
          end
          mask.size = size
          mask.save
        end
      end
    end
    

    logger_masklistimporter.debug('Masklist Importer Class() - has completed')
  end
end
