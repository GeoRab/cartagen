require 'open3'
class MapController < ApplicationController
  caches_page :find
  protect_from_forgery :except => :formats

  def index
    redirect_to "http://mapknitter.org"
#    @maps = Map.find :all, :order => 'updated_at DESC', :limit => 25
#    respond_to do |format|
#      format.html {  }
#      format.xml  { render :xml => @maps }
#      format.json  { render :json => @maps }
#    end
  end

  def edit
    redirect_to "http://mapknitter.org/maps/edit/"+params[:id]
#    @map = Map.find_by_name params[:id]
#    @export = Export.find_by_map_id(@map.id)
#    if @map.password != "" && !Password::check(params[:password],@map.password) 
#      flash[:error] = "That password is incorrect." if params[:password] != nil
#      redirect_to "/map/login/"+params[:id]+"?to=/map/edit/"+params[:id]
#    else
#      @images = Warpable.find_all_by_map_id(@map.id,:conditions => ['parent_id IS NULL AND deleted = false'])
#    end
  end

  # pt fm ac wpw
  def images
    redirect_to "http://mapknitter.org"
#    @map = Map.find_by_name params[:id]
#    @images = Warpable.find_all_by_map_id(@map.id,:conditions => ['parent_id IS NULL AND deleted = false'])
#    @image_locations = []
#    if @images
#      @images.each do |image|
#        if image.nodes != ''
#          node = image.nodes.split(',').first
#          node_obj = Node.find(node)
#          @image_locations << [node_obj.lon,node_obj.lat]
#        else
#        end
#      end
#      render :layout => false
#    else
#      render :text => "<h2>There are no images in this map.</h2>"
#    end
  end

  # just a template pointer... maybe uneccessary
  def new
  end

  def add_static_data
    @map = Map.find params[:id]
    static_data = @map.static_data.split(',')
    static_data << params[:url]
    @map.static_data = static_data.join(',')
    @map.save
  end

  def cache
    keys = params[:id].split(',')
    keys.each do |key|
      system('cd '+RAILS_ROOT+'/public/api/0.6/geohash && wget '+key+'.json')
    end
  end

  def clear_cache
      system('rm '+RAILS_ROOT+'/public/api/0.6/geohash/*.json')
  end

  def update_map
    redirect_to "http://mapknitter.org"
#    @map = Map.find(params[:map][:id])
#    if @map.password != "" && !Password::check(params[:password],@map.password) 
#      flash[:error] = "That password is incorrect." if params[:password] != nil
#      redirect_to "/map/login/"+params[:id]+"?to=/map/edit/"+params[:id]
#    else
#      @map.update_attributes(params[:map])
#      @map.author = params[:map][:author]
#      @map.description = params[:map][:description]
#  	location = GeoKit::GeoLoc.geocode(params[:map][:location])
#      @map.lat = location.lat
#      @map.lon = location.lng
#      @map.password = Password.update(params[:map][:password]) if @map.password != "" && @map.password != "*****"
#      @map.save
#      redirect_to '/map/edit/'+@map.name
#    end
  end

  def create
    redirect_to "http://mapknitter.org"
#    if params[:location] == ''
#      @map = Map.new
#      @map.errors.add :location, 'You must name a location. You may also enter a latitude and longitude instead.'
#      index
#      render :action=>"index", :controller=>"map"
#    else
#      if params[:latitude] == '' && params[:longitude] == ''
#	location = ''
#	puts 'geocoding'
#        begin
#          location = GeoKit::GeoLoc.geocode(params[:location])
#	  @map = Map.new({:lat => location.lat,
#            :lon => location.lng,
#            :name => params[:name],
#            :location => params[:location]})
#        rescue
#	  @map = Map.new({
#            :name => params[:name]})
#	end
#      else
#	puts 'nogeocoding'
#        @map = Map.new({:lat => params[:latitude],
#            :lon => params[:longitude],
#            :name => params[:name],
#            :location => params[:location]})
#      end
#      if verify_recaptcha(:model => @map, :message => "ReCAPTCHA thinks you're not a human!") && @map.save
#      #if @map.save
#        redirect_to :action => 'show', :id => @map.name
#      else
#	index
#        render :action=>"index", :controller=>"map"
#      end
#    end
  end
 
  def login
  end

  # http://www.zacharyfox.com/blog/ruby-on-rails/password-hashing 
  def show
    redirect_to "http://mapknitter.org/maps/"+params[:id]
#    @map = Map.find_by_name(params[:id],:order => 'version DESC')
#    if @map.password != "" && !Password::check(params[:password],@map.password) 
#      flash[:error] = "That password is incorrect." if params[:password] != nil
#      redirect_to "/map/login/"+params[:id]+"?to=/maps/"+params[:id]
#    else
#    @map.zoom = 1.6 if @map.zoom == 0
#    @warpables = Warpable.find :all, :conditions => {:map_id => @map.id, :deleted => false} 
#    @nodes = {}
#    @warpables.each do |warpable|
#      if warpable.nodes != ''
#        nodes = []
#        warpable.nodes.split(',').each do |node|
#          node_obj = Node.find(node)
#          nodes << [node_obj.lon,node_obj.lat]
#        end
#        @nodes[warpable.id.to_s] = nodes
#      elsif (warpable.nodes == "" && warpable.created_at == warpable.updated_at)
#	# delete warpables which have not been placed and are older than 1 hour:
#	warpable.delete if DateTime.now-1.hour > warpable.created_at
#      end
#      @nodes[warpable.id.to_s] ||= 'none'
#    end
#    if !@warpables || @warpables && @warpables.length == 1 && @warpables.first.nodes == "none"
#      location = GeoKit::GeoLoc.geocode(@map.location)
#      @map.lat = location.lat
#      @map.lon = location.lng
#	puts @map.lat
#	puts @map.lon
#      @map.save
#    end
#    render :layout => false
#    end
  end

  def search
    params[:id] ||= params[:q]
    @maps = Map.find(:all, :conditions => ['name LIKE ? OR location LIKE ? OR description LIKE ?',"%"+params[:id]+"%", "%"+params[:id]+"%", "%"+params[:id]+"%"],:limit => 100)
  end
 
  def update
    @map = Map.find(params[:id])
    @map.lat = params[:lat]
    @map.lon = params[:lon]
    @map.vectors = true if params[:vectors] == 'true'
    @map.vectors = false if params[:vectors] == 'false'
    @map.tiles = params[:tiles] if params[:tiles]
    @map.zoom = params[:zoom]
    if @map.save
      render :text => 'success'
    else
      render :text => 'failure'
    end
  end

  def geolocate
    begin
	@location = GeoKit::GeoLoc.geocode(params[:q])
	render :layout => false
    rescue
	render :text => "No results"
    end
  end
 
  def stylesheet
    render :text => Map.find_by_name(params[:id],:order => 'version DESC').styles, :layout => false
  end
  
  # displays a map for the place name in the URL: "cartagen.org/find/cambridge, MA"
  def find
    # determine range, or use default:
    if params[:range]
      range = params[:range].to_f
    end
    range ||= 0.001

    # use lat/lon or geocode a string:
    if params[:lat] && params[:lon]
      geo = GeoKit::GeoLoc.new
      geo.lat = params[:lat]
      geo.lng = params[:lon]
      geo.success = true
    else
      unless params[:id]
        params[:id] = "20 ames st cambridge"
      end
      cache = "geocode"+params[:id]
      geo = Rails.cache.read(cache)
      unless geo
        geo = GeoKit::GeoLoc.geocode(params[:id])
        Rails.cache.write(cache,geo)
      end
    end
    if params[:zoom_level]
      zoom_level = params[:zoom_level]
    else
      zoom_level = Openstreetmap.precision(geo)
    end
    if geo.success
      # use geo.precision to define a width and height for the viewport
      # set zoom_x and zoom_y accordingly in javascript... and the scale factor.
      @map = {:range => range, :zoom_level => zoom_level,:lat => geo.lat, :lng => geo.lng}
      render :layout => false
    end
  end
  
  # accepts lat1,lng1,lat2,lng2 and returns osm features for the bounding box in various formats
  def plot
    cache = "bbox="+params[:lng1]+","+params[:lat1]+","+params[:lng2]+","+params[:lat2]
    if params[:live] == true
      @features = Rails.cache.read(cache)
    end
    unless @features
      @features = Openstreetmap.features(params[:lng1],params[:lat1],params[:lng2],params[:lat2])
      Rails.cache.write(cache,@features)
    end
    respond_to do |format|
      format.html { render :html => @features, :layout => false }
      format.xml  { render :xml => @features, :layout => false }
      format.kml  { render :template => "map/plot.kml.erb", :layout => false }
      format.js  { render :json => @features, :layout => false }
    end
  end

  # accepts lat1,lng1,lat2,lng2 and returns osm features for the bounding box in various formats
  def tag
    cache = "bbox="+params[:lng1]+","+params[:lat1]+","+params[:lng2]+","+params[:lat2]
    # if params[:live] == true
    #   @features = Rails.cache.read(cache)
    # end
    # unless @features
      @features = Xapi.tag(params[:lng1],params[:lat1],params[:lng2],params[:lat2],params[:key],params[:value])
      # Rails.cache.write(cache,@features)
    # end
    respond_to do |format|
      format.html { render :html => @features, :layout => false }
      format.xml  { render :xml => @features, :layout => false }
      format.kml  { render :template => "map/plot.kml.erb", :layout => false }
      format.js  { render :json => @features, :layout => false }
    end
  end

  def formats
    redirect_to "http://mapknitter.org"
#	@map = Map.find params[:id] 
#	@export = Export.find_by_map_id(params[:id])
#	render :layout => false
  end

  def output
    redirect_to "http://mapknitter.org"
#	@map = Map.find params[:id] 
#	if @export = Export.find_by_map_id(params[:id])
#		@running = (@export.status != 'complete' && @export.status != 'none' && @export.status != 'failed')
#	else
#		@running = false
#	end
#	render :layout => false
  end

  def layers
	render :layout => false
  end

  def cancel_export
	export = Export.find_by_map_id(params[:id])
	export.status = 'none'
	export.save
	render :text => 'cancelled'
  end

  def progress
    redirect_to "http://mapknitter.org"
#	if export = Export.find_by_map_id(params[:id])
#		if  export.status == 'complete'
#			output = 'complete'
#		elsif export.status == 'none'
#			output = 'export has not been run'
#		elsif export.status == 'failed'
#			output = 'export failed'
#		else
#			output = ' <img class="export_status" src="/images/spinner-small.gif">'+ export.status
#		end
#	else
#		output = 'export has not been run'
#	end
#	render :text => output, :layout => false 
  end

  def export
    redirect_to "http://mapknitter.org"
#	map = Map.find_by_name params[:id]
#	begin
#		unless export = Export.find_by_map_id(map.id)
#			export = Export.new({:map_id => map.id,:status => 'starting'})
#		end
#		export.status = 'starting'
#		export.tms = false
#		export.geotiff = false
#		export.jpg = false
#		export.save       
#
#		directory = RAILS_ROOT+"/public/warps/"+map.name+"/"
#		stdin, stdout, stderr = Open3.popen3('rm -r '+directory)
#		puts stdout.readlines
#		puts stderr.readlines
#		stdin, stdout, stderr = Open3.popen3('rm -r '+RAILS_ROOT+'/public/tms/'+map.name)
#		puts stdout.readlines
#		puts stderr.readlines
#	
#		puts '> averaging scales'
#		pxperm = map.average_scale # pixels per meter
#	
#		puts '> distorting warpables'
#		origin = map.distort_warpables(pxperm)
#		warpable_coords = origin.pop	
#
#		export = Export.find_by_map_id(map.id)
#		export.status = 'compositing'
#		export.save
#	
#		puts '> generating composite tiff'
#		geotiff_location = map.generate_composite_tiff(warpable_coords,origin)
#	
#		info = (`identify -quiet -format '%b,%w,%h' #{geotiff_location}`).split(',')
#		puts info
#		#stdin, stdout, stderr = Open3.popen3("identify -quiet -format '%b,%w,%h' #{geotiff_location}")
#		#puts stderr.readlines
#		#info = stdout.readlines.split(',') 
#	
#		export = Export.find_by_map_id(map.id)
#		if info[0] != ''
#			export.geotiff = true
#			export.size = info[0]
#			export.width = info[1]
#			export.height = info[2]
#			export.cm_per_pixel = 100.0000/pxperm
#			export.status = 'tiling'
#			export.save
#		end
#	
#		puts '> generating tiles'
#		export = Export.find_by_map_id(map.id)
#		export.tms = true if map.generate_tiles
#		export.status = 'creating jpg'
#		export.save
#
#		puts '> generating jpg'
#		export = Export.find_by_map_id(map.id)
#		export.jpg = true if map.generate_jpg
#		export.status = 'complete'
#		export.save
#	
#	rescue SystemCallError
 # 	#	$stderr.print "failed: " + $!
#		export = Export.find_by_map_id(map.id)
#		export.status = 'failed'
#		export.save
#	end
 #       render :text => "new Ajax.Updater('formats','/map/formats/#{map.id}')"
  end
end
