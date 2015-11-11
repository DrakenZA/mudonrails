class Weapon < GameObject
  attr_reader :damage

  def initialize(params = {})
    super
    @amountofuses = params.fetch(:amountofuses, "Unlimited")
    @damage = params.fetch(:damage, 10)
  @item_name = params.fetch(:weapon_type, "Weapon")

  end


end
