module ProcessMasks
  @queue = :management

  def self.perform(name, path, group_id)
    sleep(rand(10))
    require_relative '../models/master'
    # Setup Logger
    logger = Logger.new('logs/jobs/maskProcessor.log', 'daily')
    if ENV['RACK_ENV'] == 'development'
      logger.level = Logger::DEBUG
    else
      logger.level = Logger::INFO
    end

    logger.debug('ProcessMasks Class() - has started ' + path + ' ' + name + ' ' + group_id.to_s)

    File.open(path, "r") do |file_handle|
      file_handle.each_line do |mask|
        if mask.strip.match(/\?/)
          task_obj = Tasks.new
          task_obj.name = name + ' (' + mask.strip + ')'

          task_obj.hc_attackmode = 'maskmode'
          task_obj.hc_mask = mask.strip
          task_obj.visible = '0'
          task_obj.keyspace = getKeyspace(task_obj)

          logger.debug('ProcessMasks Class() - Keyspace size for ' + mask.strip + ' is ' + task_obj.keyspace.to_s)

          task_obj.save

          if task_obj.id
            task_group = TaskGroups.first(id: group_id)
            if task_group
              if task_group.tasks.nil?
                task_group.tasks = task_obj.id.to_s
              else
                @task_group_ids = task_group.tasks.scan(/\d+/)
                if !@task_group_ids.include? task_obj.id
                  @task_group_ids.push(task_obj.id)
                  task_group.tasks = @task_group_ids.to_s
                end
              end
              task_group.save
            end
          end
        end
      end
    end
    logger.debug('ProcessMasks Class() - has completed')
  end
end
