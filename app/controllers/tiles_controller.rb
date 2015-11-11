class TilesController < ApplicationController
before_action :authenticate_user!
require 'yaml'
require_dependency 'spell'
require_dependency 'scroll'
require_dependency 'portal'
require_dependency 'weapon'

require_dependency 'game_object'


###check if tile id is present on current user###
def index
  if current_user.tile == nil
  @fix = current_user
  @fix.tile = Tile.find_by_id(1)
  @fix.save
  end
end
#################################################



@admincommands = Set.new([
  'editroom',
  'createroom',
  'createitem',
  'editroom'
  ])





def create

  @inputfromuser = params[:q]

    case @inputfromuser

    when /^use\s+(.*)$/i
      current_user.mud_use($1)


    when /^attack\s+(.*)$/i
        current_user.mud_attack1($1)

    when "help"
      current_user.sendtoplayer2(["Commands:",
        "#{mud_colortext("South,East,North,West","green")} : Move around",
        "#{mud_colortext("look","green")} : Look around the room",
        "#{mud_colortext("say TEXT","green")} : Broadcast a whole room",
        "#{mud_colortext("tell USER MSG","green")} : Send msg to user",
        "#{mud_colortext("bag","Green")} : List items in your backpack",
        "#{mud_colortext("pickup ITEM ","green")}: Lets you pickup up a item",
        "#{mud_colortext("attack Person/NPC ","green")}: Lets you attack a person or NPC",
        "#{mud_colortext("use ITEM ","green")}: Lets you use an item on the floor or in your bag",
        "Admin Commands:",
        "#{mud_colortext("editroom Property NEW_VALUE","green")} : Change the value of a room",
        "#{(mud_colortext"createroom DIRECTION DESC","green")} : Create a new room",
        "#{mud_colortext("createitem CLASS(GameObject)","green")}: lets you create an item",
        "#{mud_colortext("pickup ITEM ","green")}: Lets you pickup up a item",
      "#{mud_colortext("createnpc NPC ","green")}: Create a new NPC"],
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
      current_user.moverooms(@inputfromuser)

      when "look"
      current_user.mud_playerlook()



      when /^say\s+(.*)$/i
      current_user.tile.msgwholeroom("#{current_user.username} said: <span style=color:red>#{$1}</span>",current_user,"all")


      #tell
      when /^tell\s+(\w+)\s+(.*)$/i
      User.find_by_username($1).sendtoplayer2(["#{current_user.username} just told you #{$2}"])
      current_user.sendtoplayer2("Told #{$1} #{$2}")



      when "bag"
        current_user.mud_backpacklook()
      when "equipment"
        current_user.mud_equipmentlook()




      when /^editroom\s+(\w+)\s+(.*)$/i
        if current_user.admin == false
          current_user.sendtoplayer2("This is an admin command")
          return
        end

          current_user.editcurrentroom($1,$2)



    when /^createitem\s+(\w+)\s+(.*)$/i
      if current_user.admin == false
        current_user.sendtoplayer2("This is an admin command")
        return
      end

      current_user.mud_createitem($1,$2)




      when /^createnpc\s+(\w+)\s+(.*)$/i

        if current_user.admin == false
          current_user.sendtoplayer2("This is an admin command")
          return
        end

      current_user.mud_createnpc($1,$2)



      when /^pickup\s+(.*)$/i
      current_user.mud_playerpickup($1)

    when /^equip\s+(.*)$/i
    current_user.mud_playerequip($1)


      when /^createroom\s+(\w+)\s+(.*)$/i
        if current_user.admin == false
          current_user.sendtoplayer2("This is an admin command")
          return
        end
        current_user.createnewroom($1,$2)



#####end of the case
else
current_user.sendtoplayer2( "error")
    end




    respond_to do |format|
      format.js

    end
end




def mud_colortext(text,colour)
text = "<span style=color:#{colour}>#{text}</span>"
end


end
