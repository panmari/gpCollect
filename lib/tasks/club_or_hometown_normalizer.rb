# frozen_string_literal: true

class ClubOrHometownNormalizer
  STATIC_SUBSTITUTION_PATTERNS = { /ae/ => 'ä', /ue/ => 'ü', /oe/ => 'ö',
                                   # Accent fixes surfaced using query:
                                   # Runner.group(["f_unaccent(club_or_hometown)", :club_or_hometown])
                                   /[Gg]eneve/ => 'Genève', /Glane/i => 'Glâne',
                                   /Delemont/i => 'Delémont',
                                   /Neuchatel/i => 'Neuchâtel',
                                   /Zurich/i => 'Zürich',
                                   /(Thun)/i => ' (Thun)',
                                   /Lützelflüh-Goldb/i => 'Lützelflüh-Goldbach',
                                   /St[. ]( )*/i => 'St. ',
                                   /-s-/i => '-sur-', # e.g. Romanel-sur-Lausanne
                                   / im /i => ' im ', # Im Emmental => im Emmental.
                                   / ob /i => ' ob ', # Ob Gunten => ob Gunten.
                                   / im Kande\z/i => ' im Kandertal',
                                   / bei Aad\z/i => ' bei Aadorf',
                                   /Pre/i => 'Pré',
                                   / bei Kall(na)?/i => ' bei Kalnach',
                                   /Hasle bei \/?B\./i => 'Hasle bei Burgdorf',
                                   / a\/Albis/i => ' am Albis',
                                   /Hindelb\z/i => 'Hindelbank',
                                   /im Emmen?t?a?/i => 'im Emmental',
                                   /I\. ?E\.?\z/i => 'im Emmental',
                                   # 'an der Aare' uses similar patterns, making it
                                   # hard to make this more generic.
                                   /(?<=Affoltern|Langnau|Hausen|Kappel) A[.m]? ?A(\.|(lbis))\z/ => ' am Albis',
                                   /\ASpiegel\z/i => 'Spiegel bei Bern',
                                   /[\- ](b\.|bei)[ \-]?/i => ' bei ' }.freeze
  CANTONS = %w[AG AR BE FR GE GL LU NE NW OW SG SO SZ TG VD ZH].freeze

  def initialize(towns)
    @substitution_patterns = STATIC_SUBSTITUTION_PATTERNS.dup
    CANTONS.each do |canton|
      @substitution_patterns[/( \/ |[ \/]|, )\(?#{canton}\)?\z/i] = " #{canton}"
    end
    @towns = towns.to_set
  end

  def normalize(town)
    return town if town.nil?
    return town unless @substitution_patterns.any? do |before, _|
      before.match(town)
    end

    new_town = +town # Fancy syntax to return mutable copy of frozen string.
    @substitution_patterns.each do |before, after|
      new_town.gsub!(before, after)
    end
    return town unless @towns.include?(new_town)

    new_town
  end
end
