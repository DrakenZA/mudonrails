
class GameObject
  attr_reader :item_name
  attr_accessor :owner,:movable,:amountofuses
  def initialize(params ={})
    @item_name = params.fetch(:item_name, "blank object")
    @owner = params.fetch(:owner, ["Tile",1])
    @movable = params.fetch(:movable, true)
    @amountofuses = params.fetch(:amountofuses, 1)
  end



  def use(player)
    player.sendtoplayer2(["You dont know how to 'use' that"])



  end


  def removefromworld()

    ownerobject = @owner[0].constantize.find_by_id(@owner[1])
    ownerobject.backpack.delete_at(ownerobject.backpack.find_index{|h| h.item_name == self.item_name})
    ownerobject.save
  end


end


class NPC
  attr_reader :npc_name
  attr_accessor :hp, :owner
  def initialize(params ={})
    @npc_name = params.fetch(:npc_name, 'blank npc')
    @hp = params.fetch(:hp, 100)

  end

  def removefromworld()

    ownerobject = @owner[0].constantize.find_by_id(@owner[1])
    ownerobject.npcs.delete_at(ownerobject.npcs.find_index{|h| h.npc_name == self.npc_name})
    ownerobject.save
  end



def aggro(player)
  EM.defer do



    if player == nil
      sleep 5
    else
      player.sendtoplayer2("i see you")
      sleep 5
    end






end

end






end
