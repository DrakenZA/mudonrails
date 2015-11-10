class Portal < GameObject
  def initialize(params = {})
    super
  @portal_name = params.fetch(:portal_name, "default")
  @item_name = "portal to " + @portal_name
  @dest_tileid = params.fetch(:dest_tileid, '1')
  @movable = params.fetch(:movable, false)


  end

  def use(player)
    player.teleport(@dest_tileid)
  end
end
