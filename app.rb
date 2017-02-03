require 'sinatra'
require 'data_mapper'

 DataMapper.setup(:default, 'sqlite:////home/bhavishya/Documents/webd/mytwiterc/datatwiter.db')
set :sessions ,true
set :bind, '0.0.0.0'
set :port, '3000'
class User

	include DataMapper::Resource
	property :id, Serial
	property :name, String
	property :email, String
	property :password, String

end
class Post
	include DataMapper::Resource
	property :id, Serial
	property :user_id, Integer
	property :content, Text
	property :time , DateTime
	property :likes, Integer

end
class Likes
	include DataMapper::Resource
	property :id, Serial
	property :postId, Integer
	property :userId, Integer
end 
class Follow
	include DataMapper::Resource
	property :id, Serial
	property :follower, Integer
	property :following, Integer 
end
DataMapper.finalize
User.auto_upgrade!
Post.auto_upgrade!
Likes.auto_upgrade!
Follow.auto_upgrade!

get '/' do
	user = nil
	if session[:user_id_logged]
		user = User.get(session[:user_id_logged])
	else
		redirect'/sign_in'
	end
	posts = Post.all()
	foll = Follow.all(:follower => user.id)
	erb :index , :locals =>{:user => user, :time => Time.now , :posts => posts.reverse, :foll => foll}
end
get '/open_profile/:user' do
	uss = params[:user]
	session[:prr] = uss
	redirect '/profile'
end
get '/profile' do
 	erb :profile, :locals => {:userpas => session[:prr]}
end
get '/sign_in' do
	erb :login
end
post '/sign_in' do
	email = params[:email]
	password = params[:password]
	user = User.all(:email =>email).first
	if user
		if user.password == password
			session[:user_id_logged]=user.id
			redirect '/'
		else
			redirect '/sign_in'
		end
	else
		redirect '/sign_up'
	end
	redirect '/'
end
get '/logout' do
 	session[:user_id_logged] =  nil
 	redirect '/'
end
get '/sign_up' do
	erb :sign_up
end
post '/register' do
	user_name = params[:name]
	user_mail = params[:email]
	user_pass = params[:password]
	user = User.all(:email => user_mail).first
	if user
		redirect '/sign_up'
	else
		user = User.new
		user.name = user_name
		user.email = user_mail
		user.password = user_pass
		user.save
		session[:user_id_logged] = user.id
		redirect '/'
	end
end
post '/add_post' do
	if params[:content] == "what's in your mind!"
		redirect '/'
	end
	post_a = Post.new
	post_a.content = params[:content]
	post_a.time = Time.now
	post_a.user_id = session[:user_id_logged]
	post_a.likes = 0;
	post_a.save
	redirect '/'
end
get '/like/:post_id' do
	puts "....................................#{params[:post_id]}"
	post = Post.get(params[:post_id])
	all_likes = Likes.all(:postId => post.id)
	if_like = all_likes.all(:userId => session[:user_id_logged])
	if if_like.first == nil
		if(post.likes)
			post.likes +=1
		else
			post.likes = 0
		end
		post.save
	end
	like_d = Likes.new
	like_d.postId = post.id
	like_d.userId = session[:user_id_logged]
	like_d.save
	redirect '/'
end
post '/unfoll' do
	unf = Follow.all(:follower => session[:user_id_logged])
	unfentry = unf.all(:following => params[:unfollowH])
	entry = unfentry.first
	entry.destroy
	redirect '/' 
end
post '/foll' do
	entry = Follow.new
	entry.follower = session[:user_id_logged]
	entry.following = params[:followH]
	entry.save
	redirect '/'
end
