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
end
