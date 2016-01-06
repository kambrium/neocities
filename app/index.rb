get '/?' do
  if current_site
    require_login

    redirect '/dashboard' if current_site.is_education

    @suggestions = current_site.suggestions

    @page = params[:page].to_i
    @page = 1 if @page == 0

    if params[:activity] == 'mine'
      events_dataset = current_site.latest_events(@page, 10)
    elsif params[:event_id]
      event = Event.select(:id).where(id: params[:event_id]).first
      not_found if event.nil?
      not_found if event.is_deleted
      events_dataset = Event.where(id: params[:event_id]).paginate(1, 1)
    elsif params[:activity] == 'global'
      events_dataset = Event.global_dataset @page
    else
      events_dataset = current_site.news_feed(@page, 10)
    end

    @pagination_dataset = events_dataset
    @events = events_dataset.all

    current_site.events_dataset.update notification_seen: true

    halt erb :'home', locals: {site: current_site}
  end

  if SimpleCache.expired?(:sites_count)
    @sites_count = SimpleCache.store :sites_count, Site.count.roundup(100), 600 # 10 Minutes
  else
    @sites_count = SimpleCache.get :sites_count
  end

  erb :index, layout: :index_layout
end

get '/welcome' do
  require_login
  redirect '/' if current_site.plan_type != 'free'
  erb :'welcome', locals: {site: current_site}
end

get '/education' do
  redirect '/' if signed_in?
  erb :education, layout: :index_layout
end

get '/donate' do
  erb :'donate'
end

get '/about' do
  erb :'about'
end

get '/terms' do
  erb :'terms'
end

get '/privacy' do
  erb :'privacy'
end

get '/press' do
  erb :'press'
end

get '/legal/?' do
  @title = 'Legal Guide to Neocities'
  erb :'legal'
end

get '/permanent-web' do
  erb :'permanent_web'
end

get '/thankyou' do
  erb :'thankyou'
end
