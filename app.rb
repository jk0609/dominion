
require("bundler/setup")
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
also_reload('lib/**/*.rb')

get('/') do
  @board = Supply.order('card_id ASC').board
  Deck.destroy_all
  Deck.setup
  Player.all.each {|player| player.draw_hand(5)}
  @player = Player.all.sample
  @player.player_num.to_i+1>Player.all.length ? (@next_player=1):(@next_player=@player.player_num.to_i+1)
  erb(:index)
end

post('/:id') do
  @board = Supply.order('card_id ASC').board
  @player = Player.find_player(params[:id].to_i)
  last_player = Player.find_player(params[:last_player].to_i)
  last_player.discard_hand
  last_player.draw_hand(5)
  @player.player_num.to_i+1>Player.all.length ? (@next_player=1):(@next_player=@player.player_num.to_i+1)
  erb(:index)
end

#ajax methods
get('/draw') do
  player = Player.find_player(params[:id].to_i)
  player.draw_hand(params[:number_to_draw].to_i)
  hand = player.hand
  hand.push({:deck=>player.deck_size})
  return hand.to_json
end

get('/buy') do
  player = Player.find_player(params[:id].to_i)
  supply = Supply.where(card_id: params[:card_id].to_i)
  supply[0].gain_card(player)
  if Supply.game_over?
    return Player.winners.to_json
  else
    #return player.total_victory_points
    return [supply[0].amount, player.total_victory_points, false].to_json
  end
end

get('/trash') do
  player = Player.find_player(params[:id].to_i)
  card = Card.where(id: params.fetch('card_id'))
  player.trash_card(card)
end

get('/discard') do
  Deck.find(params[:deck_id].to_i).update({:location=>'discard'})
  return 'test'
end

get('/kill')do
  Supply.destroy_all
  Player.destroy_all
  Deck.destroy_all
  Card.destroy_all
  Supply.reset_game
  Player.reset_game
  redirect('/')
end
