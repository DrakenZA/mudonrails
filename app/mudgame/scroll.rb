class Scroll < GameObject
  attr_reader :spell_to_cast
  def initialize(params = {})
    super
  @spell_to_cast = params.fetch(:spell_to_cast, Spell.new({:spell_name => "Fireball",:spell_effect => "boom"}) )
  @item_name = "Scroll of " + @spell_to_cast.spell_name
  end




  def use(player)

    @spell_to_cast.castspell(player)
    if @amountofuses == 'Unlimited'
      return
    end

    
      ownerobject = @owner[0].constantize.find_by_id(@owner[1])
      ownerobject.backpack[ownerobject.backpack.find_index{|h| h.item_name == self.item_name}].amountofuses -= 1
      ownerobject.save
      removefromworld() if @amountofuses <= 1

  end




end
