class Tile < ActiveRecord::Base
  has_many :users

  serialize :exits, Hash
  serialize :npcs, Array

  serialize :backpack, Array

  require_dependency 'spell'
  require_dependency 'game_object'
  require_dependency 'scroll'
  require_dependency 'portal'
  require_dependency 'weapon'




  ####### send text to all players in tile (meesage to send, tile to send to) #######
  def msgwholeroom(msg,sender,type="notself")
    mtile = self
    sender.sendtoplayer2("#{msg}") if type == "all"
    mtile.users.each do | l |
      l.sendtoplayer2("#{msg}") if sender != l
    end
  end
  ###################################################################################




end
