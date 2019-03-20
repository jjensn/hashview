get '/masks/list' do
  @static_masks = Masks.all
  @tasks = Tasks.all
  @jobtasks = Jobtasks.all
  haml :mask_list
end

get '/masks/add' do
  haml :mask_add
end

get '/masks/delete/:id' do
  varWash(params)

  @mask = Masks.first(id: params[:id])
  if !@mask
    flash[:error] = 'No such mask exists. '
    redirect to('/masks/list')
  else
    # check if mask is in use
    @task_list = Tasks.where(wl_id: params[:id]).all
    unless @task_list.empty?
      flash[:error] = 'This word list is associated with a task, it cannot be deleted.'
      redirect to('/masks/list')
    end

    # Remove from filesystem
    begin
      File.delete(@mask.path)
    rescue
      flash[:warning] = 'No file found on disk.'
    end

    # delete from db
    @mask.destroy

  end
  redirect to('/masks/list')
end

post '/masks/upload/' do
  varWash(params)

  if !params[:file] || params[:file].nil?
    flash[:error] = 'You must specify a file.'
    redirect to('/masks/add')
  end
  if !params[:name] || params[:name].empty?
    flash[:error] = 'You must specify a name for your mask.'
    redirect to('/masks/add')
  end

  # Replace white space with underscore.  We need more filtering here too
  upload_name = params[:name]
  upload_name = upload_name.downcase.tr(' ', '_')

  # Change to date/time ?
  rand_str = rand(36**36).to_s(36)

  # Save to file
  file_name = "control/masks/mask-#{upload_name}-#{rand_str}.txt"

  File.open(file_name, 'wb') { |f| f.write(params[:file][:tempfile].read) }
  Resque.enqueue(MasklistImporter)

  redirect to('/masks/list')
end
