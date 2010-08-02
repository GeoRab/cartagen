class MapController < ApplicationController
  caches_page :find

  def index
    @maps = Map.find :all, :order => 'updated_at DESC', :limit => 25
  end

  def edit
    @map = Map.find_by_name params[:id]
    @images = Warpable.find_all_by_map_id(@map.id,:conditions => ['parent_id IS NULL AND deleted = false'])
  end

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
    @map = Map.find(params[:map][:id])
    @map.update_attributes(params[:map])
    location = GeoKit::GeoLoc.geocode(params[:map][:location])
    @map.lat = location.lat
    @map.lon = location.lng
    @map.save
    flash[:notice] = "Saved map."
    redirect_to '/map/edit/'+@map.name
  end

  def create
    if params[:location] == ''
      @map = Map.new
      @map.errors.add :location, 'You must name a location. You may also enter a latitude and longitude instead.'
      index
      render :action=>"index", :controller=>"map"
    else
      if params[:latitude] == '' && params[:longitude] == ''
	location = ''
	puts 'geocoding'
        begin
          location = GeoKit::GeoLoc.geocode(params[:location])
	  @map = Map.new({:lat => location.lat,
            :lon => location.lng,
            :name => params[:name],
            :location => params[:location]})
        rescue
	  @map = Map.new({
            :name => params[:name]})
	end
      else
	puts 'nogeocoding'
        @map = Map.new({:lat => params[:latitude],
            :lon => params[:longitude],
            :name => params[:name],
            :location => params[:location]})
      end
      if @map.save
        redirect_to :action => 'show', :id => @map.name
      else
	index
        render :action=>"index", :controller=>"map"
      end
    end
  end
  
  def show
    @map = Map.find_by_name(params[:id],:order => 'version DESC')
    @map.zoom = 1.6 if @map.zoom == 0
    @warpables = Warpable.find :all, :conditions => {:map_id => @map.id, :deleted => false} 
    @nodes = {}
    @warpables.each do |warpable|
      if warpable.nodes != ''
        nodes = []
        warpable.nodes.split(',').each do |node|
          node_obj = Node.find(node)
          nodes << [node_obj.lon,node_obj.lat]
        end
        @nodes[warpable.id.to_s] = nodes
      else
      end
      @nodes[warpable.id.to_s] ||= 'none'
    end
    render :layout => false
  end

  def search
    params[:id] ||= params[:q]
    @maps = Map.find(:all, :conditions => ['name LIKE ? OR location LIKE ? OR description LIKE ?',"%"+params[:id]+"%", "%"+params[:id]+"%", "%"+params[:id]+"%"],:limit => 100)
  end
 
  def update
    @map = Map.find(params[:id])
    @map.lat = params[:lat]
    @map.lon = params[:lon]
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

  def output
	@map = Map.find params[:id] 
	if @export = Export.find_by_map_id(params[:id])
		@running = (@export.status != 'complete' && @export.status != 'none' && @export.status != 'failed')
	else
		@running = false
	end
	render :layout => false
  end

  def layers

	render :layout => false

  end

  def progress
	if export = Export.find_by_map_id(params[:id])
		if  export.status == 'complete'
			output = 'complete'
		elsif export.status == 'none'
			output = 'export has not been run'
		elsif export.status == 'failed'
			output = 'export failed'
		else
			output = ' <img class="export_status" src="/images/spinner-small.gif">'+ export.status
		end
	else
		output = 'export has not been run'
	end
	render :text => output, :layout => false 
  end

  def export
	map = Map.find_by_name params[:id]
	begin

		unless export = Export.find_by_map_id(map.id)
			export = Export.new({:map_id => map.id,:status => 'starting'})
		end
		export.geotiff = true
		export.status = 'starting'
		export.save       
	 
		directory = "public/warps/"+map.name+"/"
	    	`rm -r #{directory}`
		`rm -r public/tms/#{map.name}/`
	
		puts '> averaging scales'
		pxperm = map.average_scale # pixels per meter
	
		puts '> distorting warpables'
		origin = map.distort_warpables(pxperm)
		warpable_coords = origin.pop	
		
		export = Export.find_by_map_id(map.id)
		export.status = 'compositing'
		export.save
	
		puts '> generating composite tiff'
		geotiff_location = map.generate_composite_tiff(warpable_coords,origin)
	
		info = (`identify -quiet -format '%b,%w,%h' #{geotiff_location}`).split(',')
	
		export = Export.find_by_map_id(map.id)
		export.size = info[0]
		export.width = info[1]
		export.height = info[2]
		export.cm_per_pixel = 100.0000/pxperm
		export.status = 'tiling'
		export.save
	
		puts '> generating tiles'
		export = Export.find_by_map_id(map.id)
		export.tms = true if map.generate_tiles
		export.status = 'complete'
		export.save
	
		render :text => '<a href="/warps/'+map.name+'/'+map.name+'-geo.tif">'+map.name+'-geo.tif</a>'
	rescue
		export = Export.find_by_map_id(map.id)
		export.status = 'failed'
		export.save
	end
   return :text => 'started export'
  end

end
