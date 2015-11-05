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


    when "help"
      sendtoplayer2(current_user,["Commands:",
        "South,East,North,West : Move around",
        "look : Look around the room",
        "say <text> : Broadcast a whole room",
        "tell <user> <msg> : Send <msg> to <user>",
        "bag : List items in your backpack",
        "Admin Commands:",
        "editroom <property> <new value> : Change the value of a room",
        "createroom <direction> <desc> : Create a new room",
        "createitem <name> : lets you create an item","pickup <item> : Lets you pickup up a item"],
        ["blue",
          "red",
          "red",
          "red",
          "red",
          "red",
        "blue",
      "red",
      "red",
      "red",
      "red"]
          )



      when "north", "south", "east", "west"
      moverooms(@inputfromuser,current_user)

      when "look"
      mud_playerlook(current_user)

      when /^jump\s+(.*)$/i
      sendtoplayer2(current_user,"You Jumped!")

      when /^say\s+(.*)$/i
      msgwholeroom($1,current_user.tile,"all")


      #tell
      when /^tell\s+(\w+)\s+(.*)$/i
      sendtoplayer2(User.find_by_username($1), ["#{current_user.username} just told you #{$2}"])
      sendtoplayer2(current_user, "Told #{$1} #{$2}")



      when "bag"
      sendtoplayer2(current_user,["Current items in your back", current_user.backpack ])



      when /^editroom\s+(\w+)\s+(.*)$/i
        if current_user.admin?
          editcurrentroom($1,$2)
        else
          sendtoplayer2(current_user,"This is an admin command")
        end




      when /^createitem\s+(.*)$/i
        if current_user.admin?
          if current_user.tile.backpack
            objectshere = []
            objectshere = YAML.load(current_user.tile.backpack)
            objectshere << $1
            else
            objectshere = [$1]
          end
          current_user.tile.backpack = YAML.dump(objectshere)
          current_user.tile.save
          sendtoplayer2(current_user,"You just created a #{$1} here")



          else
          sendtoplayer2(current_user,"This is an admin command")
        end

######problems next fixing
      when /^pickup\s+(.*)$/i
      mud_playerpickup(current_user,$1)


      when /^createroom\s+(\w+)\s+(.*)$/i
      if current_user.admin?
        createnewroom($1,$2)
      else
        sendtoplayer2(current_user,"This is an admin command")
      end



#####end of the case
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

def moverooms(dir,player)
  ##########Setting up the direction to move#############
  #changex = String.new
  #changy = String.new
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
  if Tile.find_by_xcoord_and_ycoord(player.tile.xcoord+changex, player.tile.ycoord+changey) == nil
    sendtoplayer2(player, "that is a void")
    return
  end
  ########################################################################################


  goto = Tile.find_by_xcoord_and_ycoord(player.tile.xcoord+changex, player.tile.ycoord+changey)
  msgwholeroom("#{player.username} just left #{dir}",player.tile)
  player.tile = goto
  player.save
  mud_playerlook(player)
  msgwholeroom("#{player.username} just entered the room",player.tile)


end

#######send text to player with (player name, message to send(can be array or string)) #######
def sendtoplayer2(player, tosend,colours=[])

  if tosend.class == String
    packet = [tosend]
  else
    packet = tosend
  end
  packetcolour = []
  count = 0
packet.each do |l|
  packetcolour[count] = "<ul style='color:#{colours[count]}'>#{l}</ul>"
count +=1
end

  PrivatePub.publish_to "/link/#{player.id}", :chat => packetcolour
end
##############################################################################################



####### send text to all players in tile (meesage to send, tile to send to) #######
def msgwholeroom(msg,mtile,type="notself")
  sendtoplayer2(current_user,"#{current_user.username} says,'#{msg}'") if type == "all"
  mtile.users.each do | l |
    sendtoplayer2(l,"#{current_user.username} says,'#{msg}'") if l != current_user
  end
end
###################################################################################


####### create new room (direction, desc of the room) #######
def createnewroom(dir, roomdesc)
  ##########Setting up the direction to move#############
  #changex = String.new
  #changy = String.new
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
  if @currenttile.exits
    exitsvar = YAML.load(@currenttile.exits)
    exitsvar.merge!({dir => @newtile.id})
  else
    exitsvar = {}
    exitsvar = {dir => @newtile.id}
  end
  @currenttile.exits = YAML.dump(exitsvar)
  @currenttile.save
  sendtoplayer2(current_user,"Created new room to the #{dir}")
end
#############################################################



def mud_playerlook(player)
  player.tile.users.each do | l |
    @playershere << l.username + ' ' if l != player
  end

  sendtoplayer2(player, [player.tile.desc,"Current exits:#{YAML.load(player.tile.exits)}","Current people here:#{@playershere}","current objects here:#{YAML.load(player.tile.backpack)}"],["blue","red","green"])

end




def mud_playerpickup (player,item)
  objectshere = []
objectshere = YAML.load(player.tile.backpack)
if objectshere.include?(item)
  objectshere.delete(item)
  player.tile.backpack = YAML.dump(objectshere)
  player.tile.save
  if player.backpack == '' || player.backpack == nil
    objectsonuser = [item]
  else
  objectsonuser = YAML.load(player.backpack)
  objectsonuser << item
  end


  player.backpack = YAML.dump(objectsonuser)
  player.save
  sendtoplayer2(player,"Picked up #{item}")
else
  sendtoplayer2(player,"No item with that name here")
end
end

#######OLD VERSION send text to player with (player name, message to send) #######
#def sendtoplayer(player, tosend)
#  client = Faye::Client.new('http://localhost:8080/faye')
#  client.publish("/link#{player.id}", {
#  :message => "<ul>#{tosend}</ul>"
#  })
#end
#######################################################################

end
