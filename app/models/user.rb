class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  belongs_to :tile
  #validates_uniqueness_of :username
  serialize :backpack, Array

  require_dependency 'spell'
  require_dependency 'game_object'
  require_dependency 'scroll'
  require_dependency 'portal'
  require_dependency "weapon"




  def mud_use(item)
  itemtouse = self.backpack.select { | h | h.item_name == item }
  itemtouse = self.tile.backpack.select { | h | h.item_name == item } if itemtouse == []

    if itemtouse == []
      self.sendtoplayer2(["You cant see that item anywhere"])
      return
    end

    itemtouse = itemtouse[0]
    itemtouse.use(self)
  end











    def mud_createnpc(npctype,info)
        case npctype
        when "NPC"
        objectshere = []
        objectshere = self.tile.npcs
        newitem = npctype.constantize.new( eval(info) )
        newitem.owner = ["Tile",self.tile.id]
        objectshere << newitem


        self.tile.npcs = objectshere
        self.tile.save
        self.sendtoplayer2("You just created a #{newitem.npc_name} here")

      else
        self.sendtoplayer2("you cant do that, npc with class npc")
        end


    end







  def mud_createitem(itemtype,info)
    case itemtype
    when "Scroll","Portal","Weapon"
      objectshere = []
      objectshere = self.tile.backpack
      newitem = itemtype.constantize.new( eval(info) )
      newitem.owner = ["Tile",self.tile.id]
      objectshere << newitem


    self.tile.backpack = objectshere
    self.tile.save
    self.sendtoplayer2("You just created a #{newitem.item_name} here")
  else
    self.sendtoplayer2("you cant create object with that class")
    end
  end



  def mud_backpacklook()
    itemsinbag = []
    self.backpack.each do |l|
      itemsinbag << l.item_name
    end
  self.sendtoplayer2(["Current items in your back", itemsinbag ])
  end


  def mud_playerlook()

    playershere = []
    self.tile.users.each do | l |
      playershere << l.username + ' ' if l != self
    end

    itemsinbag = []
    self.tile.backpack.each do |l|
      itemsinbag << l.item_name
    end

    npcsinbag = []
    self.tile.npcs.each do |l|
      npcsinbag << l.npc_name
    end

    sendtoplayer2([self.tile.desc,"Current exits:#{self.tile.exits.keys.to_s}","Current people here:#{playershere}","current objects here:#{itemsinbag}","Current NPCS here: #{npcsinbag}"],["blue","red","green","yellow","orange"])

  end



  #######send text to player with (player name, message to send(can be array or string)) #######
  def sendtoplayer2(tosend,colours=[])

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

    PrivatePub.publish_to "/link/#{self.id}", :chat => packetcolour
  end
  ##############################################################################################


  def editcurrentroom(prop,newvalue)
    case prop
    when "desc"
      room = self.tile
      room.desc = newvalue
      room.save
      self.sendtoplayer2("Changed current rooms desc")

    when "lol"
    else
    self.sendtoplayer2( "error unknown property")

    end

  end



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
    if Tile.find_by_xcoord_and_ycoord(self.tile.xcoord+changex, self.tile.ycoord+changey) != nil
      self.sendtoplayer2( "there is already a room in that exit direction")
      return
    end

    @newtile = Tile.new
    @newtile.xcoord = self.tile.xcoord+changex
    @newtile.ycoord = self.tile.ycoord+changey
    @newtile.desc = roomdesc
    exitsvar = {reversedir(dir) => self.tile.id}
    @newtile.exits = exitsvar
    @newtile.save
    @currenttile = self.tile
    if @currenttile.exits
      exitsvar = @currenttile.exits
      exitsvar.merge!({dir => @newtile.id})
    else
      exitsvar = {}
      exitsvar = {dir => @newtile.id}
    end
    @currenttile.exits = exitsvar
    @currenttile.save
    self.sendtoplayer2("Created new room to the #{dir}")
  end
  #############################################################

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



  def teleport(tilegoto='')
    if Tile.find_by_id(tilegoto) == nil
      self.sendtoplayer2(["The portal leads to nothing"])
      return
    end


      self.tile = Tile.find_by_id(tilegoto)
      self.save
      self.sendtoplayer2("You slip through the portal",["orange"])
      self.mud_playerlook()

  end


  def moverooms(dir)
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


    ############################checking of the tile even exists##############################
    if Tile.find_by_xcoord_and_ycoord(self.tile.xcoord+changex, self.tile.ycoord+changey) == nil
      self.sendtoplayer2( "that is a void")
      return
    end
    ########################################################################################


    goto = Tile.find_by_xcoord_and_ycoord(self.tile.xcoord+changex, self.tile.ycoord+changey)
    self.tile.msgwholeroom("#{self.username} just left #{dir}",self)
    self.tile = goto
    self.save
    self.mud_playerlook
    self.tile.msgwholeroom("#{self.username} just entered the room",self)


  end



  def mud_playerpickup (item)
    objectshere = []
    objectshere = self.tile.backpack
    itemtopickup = objectshere.select { | h | h.item_name == item }
    itemtopickup = itemtopickup[0]

  if itemtopickup == nil || itemtopickup.movable = false
    self.sendtoplayer2("No item with that name here,or it can not be taken")
    return
  end


    objectshere.delete_at(objectshere.index(itemtopickup) || objectshere.length)
    self.tile.backpack = objectshere
    self.tile.save


    itemtopickup.owner = ["User",self.id]

    objectsonuser = self.backpack
    objectsonuser.push(itemtopickup)



    self.backpack = objectsonuser
    self.save
    self.sendtoplayer2("Picked up #{item}")

  end

  def mud_attack1(target)

    worldtile = self.tile.npcs
    targettoattack = worldtile.select { | h | h.npc_name == target }
    targettoattack = targettoattack[0]


    if targettoattack == [] || targettoattack == nil
      self.sendtoplayer2("Nothing with that name")
      return
    end


      targettoattack.hp = targettoattack.hp - 10
      self.sendtoplayer2("You hit #{targettoattack.npc_name}")


       targettoattack.aggro(self)



      if targettoattack.hp < 1
        self.sendtoplayer2("You killed #{targettoattack.npc_name}")
        targettoattack.removefromworld()
        self.tile.npcs.delete_at(self.tile.npcs.find_index{|h| h.npc_name == targettoattack.npc_name})
        self.tile.save
        return
      end


      if self.hp < 1
        self.sendtoplayer2("#{targettoattack.npc_name} killed you")
      end


      self.tile.npcs[self.tile.npcs.find_index{|h| h.npc_name == targettoattack.npc_name}].hp = targettoattack.hp
      self.tile.save
      targettoattack = nil



      EM.defer do
        sleep 3
        self.sendtoplayer2('Attack ready')
      end


  end










end
