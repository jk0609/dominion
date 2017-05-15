require 'spec_helper'

describe Player do

  describe '#cards' do
    it 'returns cards associated with the player' do
      player = Player.create(name: 'Ilene')
      expect(player.cards).to eq([])
    end
  end

  describe '#shuffle_deck' do
    it "shuffles the deck and puts it into the draw pile" do
      player = Player.create(name: 'Ilene')
      card = Card.create(name: 'Province')
      5.times do
        Deck.create(player_id: player.id, card_id: card.id)
      end
      player.shuffle_deck
      draw = Deck.where(player_id: player.id, location: 'draw')
      expect(draw.length).to eq(5)
    end
  end

  describe '#draw_hand' do
    it "moves 5 cards from draw location into hand location" do
      player = Player.create(name: 'Ilene')
      card = Card.create(name: 'Province')
      5.times do
        Deck.create(player_id: player.id, card_id: card.id)
      end
      player.shuffle_deck
      player.draw_hand
      hand = Deck.where(player_id: player.id, location: "hand")
      expect(hand.length).to eq(5)
    end
  end

  describe '#draw_hand' do
    it "moves 5 cards from draw location into hand location" do
      player = Player.create(name: 'Ilene')
      card = Card.create(name: 'Province')
      3.times do
        Deck.create(player_id: player.id, card_id: card.id)
        Deck.update(location: 'draw')
      end
      2.times do
        Deck.create(player_id: player.id, card_id: card.id)
      end
      player.draw_hand
      expect(Deck.where(player_id: player.id, location: "hand").length).to eq(5)
    end
  end
end