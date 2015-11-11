class Spell
  attr_reader :spell_name, :spell_effect

  def initialize(params = {})

      @spell_name = params.fetch(:spell_name, "fireball")

      @spell_effect = params.fetch(:spell_effect, "BOOM")

      @item_name = "Scroll of " + @spell_name
  end


def castspell(player)
  player.sendtoplayer2(["#{player.username} #{self.spell_effect}"])
#  spell_effect.constantize

end




end
