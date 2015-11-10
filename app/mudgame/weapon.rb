class Weapon < GameObject
  def initialize(params = {})
    super
    @amountofuses = params.fetch(:amountofuses, "Unlimited")

  @item_name = params.fetch(:weapon_type, "Weapon")

  end
end
