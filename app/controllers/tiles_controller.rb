class TilesController < ApplicationController
before_action :authenticate_user!
require 'yaml'


###check if tile id is present on current user###
def index
  if current_user.tile == nil
  @fix = current_user
  @fix.tile = Tile.find_by_id(1)
  @fix.save
  end
  end
#################################################





def create
  @inputfromuser = params[:q]
  @playershere = ''
    case @inputfromuser


      when /^createroom\s+(\w+)\s+(.*)$/i
        createnewroom($1,$2)


      when "north", "south", "east", "west"
      moverooms(@inputfromuser,current_user)

      when "look"
      current_user.tile.users.each do | l |
        @playershere << l.username + ' ' if l != current_user
      end
      sendtoplayer2(current_user, [current_user.tile.desc,current_user.tile.exits,"Current people here:#{@playershere}"])


      when /^jump\s+(.*)$/i
      sendtoplayer2(current_user,"You Jumped!")

      when /^say\s+(.*)$/i
      msgwholeroom($1,current_user.tile,"all")


      #tell
      when /^tell\s+(\w+)\s+(.*)$/i
      sendtoplayer2(User.find_by_username($1), ["#{current_user.username} just told you #{$2}"])
      sendtoplayer2(current_user, "Told #{$1} #{$2}")

      when "bag"
      sendtoplayer2(current_user, "bag is empty")

      when /^editroom\s+(\w+)\s+(.*)$/i
      editcurrentroom($1,$2)

      else
      sendtoplayer2(current_user, "error")
    end




    respond_to do |format|
      format.js

    end
  end

def editcurrentroom(prop,newvalue)
  case prop
  when "desc"
    room = current_user.tile
    room.desc = newvalue
    room.save
    sendtoplayer2(current_user, "Changed current rooms desc")

  when lol
  else
  sendtoplayer2(current_user, "error unknown property")

  end

end


def reversedir(dir)
  case dir
  when "north"
    return "south"
  when "south"
    return "north"
  when "east"
    return "west"
  when "west"
    return "east"
  end
end

def moverooms(dir,p)
  ##########Setting up the direction to move#############
  changex = String.new
  changy = String.new
  case dir
  when "north"
  changex = 1
  changey = 0
  when "south"
  changex = -1
  changey = 0
  when "east"
  changex = 0
  changey = +1
  when "west"
  changex = 0
  changey = -1
  end
  ############################################################


  ############################checking of the tile even exits##############################
  if Tile.find_by_xcoord_and_ycoord(current_user.tile.xcoord+changex, current_user.tile.ycoord+changey) == nil
    sendtoplayer2(current_user, "that is a void")
    return
  end
  ########################################################################################


  goto = Tile.find_by_xcoord_and_ycoord(current_user.tile.xcoord+changex, current_user.tile.ycoord+changey)
  msgwholeroom("#{current_user.username} just left #{dir}",current_user.tile)
  current_user.tile = goto
  current_user.save
  sendtoplayer2(current_user, [current_user.tile.desc,current_user.tile.exits])
  msgwholeroom("#{p.username} just entered the room",current_user.tile)


end

#######send text to player with (player name, message to send(can be array or string)) #######
def sendtoplayer2(player, tosend)
  if tosend.class == String
    packet = [tosend]
  else
    packet = tosend
  end


  #client = Faye::Client.new('http://localhost:8080/faye')
  client = Faye::Client.new('http://drakenfaye.herokuapp.com/faye')

  client.publish("/link#{player.id}", {
  :message => packet
  })
end
##############################################################################################



####### send text to all players in tile (meesage to send, tile to send to) #######
def msgwholeroom(msg,mtile,type="notself")
  sendtoplayer2(current_user,"#{current_user.username} says,'#{msg}'") if type == "all"
  mtile.users.each do | l |
    sendtoplayer2(l,msg) if l != current_user
  end
end
###################################################################################


####### create new room (direction, desc of the room) #######
def createnewroom(dir, roomdesc)
  ##########Setting up the direction to move#############
  changex = String.new
  changy = String.new
  case dir
  when "north"
    changex = 1
    changey = 0
  when "south"
    changex = -1
    changey = 0
  when "east"
    changex = 0
    changey = +1
  when "west"
    changex = 0
    changey = -1
  end
  ############################################################


  ############################checking of the tile even exits##############################
  if Tile.find_by_xcoord_and_ycoord(current_user.tile.xcoord+changex, current_user.tile.ycoord+changey) != nil
    sendtoplayer2(current_user, "there is a room in that exit direction")
    return
  end

  @newtile = Tile.new
  @newtile.xcoord = current_user.tile.xcoord+changex
  @newtile.ycoord = current_user.tile.ycoord+changey
  @newtile.desc = roomdesc
  exitsvar = {reversedir(dir) => current_user.tile.id}
  @newtile.exits = YAML.dump(exitsvar)
  @newtile.save
  @currenttile = current_user.tile
  if @currenttile.exits != nil
    exitsvar = YAML.load(@currenttile.exits)
    exitsvar.merge!({dir => @newtile.id})
  else
    exitsvar = {dir => @newtile.id}
  end
  @currenttile.exits = YAML.dump(exitsvar)
  @currenttile.save
  sendtoplayer2(current_user,"Created new room to the #{dir}")
end
#############################################################



#######OLD VERSION send text to player with (player name, message to send) #######
#def sendtoplayer(player, tosend)
#  client = Faye::Client.new('http://localhost:8080/faye')
#  client.publish("/link#{player.id}", {
#  :message => "<ul>#{tosend}</ul>"
#  })
#end
#######################################################################
end
