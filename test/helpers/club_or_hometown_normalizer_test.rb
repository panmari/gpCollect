# frozen_string_literal: true

require 'test_helper'
require 'rspec/expectations'
require_relative '../../lib/tasks/club_or_hometown_normalizer'

class ClubOrHometownNormalizerTest < ActionController::TestCase
  include RSpec::Matchers
  TOWNS = ['Zurich', 'Zürich',
           'Koeniz', 'Köniz', 'Spiegel',
           'Spiegel b. bern', 'Spiegel b. Bern', 'Spiegel bei Bern',
           'Villars-sur-Glâne', 'Villars-sur-Glane',
           'Geneve', 'GenevE', 'Genève',
           'Club des Panards Migros Genève',
           'Neuchatel', 'Neuchâtel',
           'Delemont', 'Delémont',
           'Schüpfheim (LU)', 'Schüpfheim Lu', 'Schüpfheim LU',
           'Pfäffikon Sz', 'Pfäffikon SZ',
           'St.Gallen', 'Sankt Gallen', 'St. Gallen',
           'Langnau i.E.', 'Langnau im Emmental',
           'Reichenbach im Kandertal'].freeze

  setup do
    @normalizer = ClubOrHometownNormalizer.new(TOWNS)
  end

  test 'should normalize umlaut when written as ae/oe/ue' do
    expect(@normalizer.normalize('Koeniz')).to eq('Köniz')
  end

  test 'should normalize umlaut when written as a/o/u' do
    expect(@normalizer.normalize('Zurich')).to eq('Zürich')
  end

  test 'should upcase first letter' do
    expect(@normalizer.normalize('zürich')).to eq('Zürich')
  end

  test 'should normalize b. to bei' do
    expect(@normalizer.normalize('Spiegel b. Bern')).to eq('Spiegel bei Bern')
  end

  test 'should normalize Spiegel to full name' do
    expect(@normalizer.normalize('Spiegel')).to eq('Spiegel bei Bern')
  end

  test 'should normalize (some) french accents' do
    expect(@normalizer.normalize('Geneve')).to eq('Genève')
    expect(@normalizer.normalize('GenevE')).to eq('GenevE')
    expect(@normalizer.normalize('Villars-sur-Glane')).to eq('Villars-sur-Glâne')
    expect(@normalizer.normalize('Neuchatel')).to eq('Neuchâtel')
    expect(@normalizer.normalize('Delemont')).to eq('Delémont')

  end

  test 'should normalize cantons suffix' do
    expect(@normalizer.normalize('Schüpfheim (LU)')).to eq('Schüpfheim LU')
    expect(@normalizer.normalize('Schüpfheim Lu')).to eq('Schüpfheim LU')
    expect(@normalizer.normalize('Schüpfheim / LU')).to eq('Schüpfheim LU')
    expect(@normalizer.normalize('Schüpfheim, LU')).to eq('Schüpfheim LU')
    expect(@normalizer.normalize('Schüpfheim/LU')).to eq('Schüpfheim LU')
    expect(@normalizer.normalize('Pfäffikon Sz')).to eq('Pfäffikon SZ')
  end

  test 'should normalize "St." prefix' do
    expect(@normalizer.normalize('St Gallen')).to eq('St. Gallen')
    expect(@normalizer.normalize('st Gallen')).to eq('St. Gallen')
  end

  test 'should normalize "im Emmental" suffix' do
    expect(@normalizer.normalize('Langnau i.E.')).to eq('Langnau im Emmental')
    expect(@normalizer.normalize('Langnau i. E.')).to eq('Langnau im Emmental')
    expect(@normalizer.normalize('Langnau I.E')).to eq('Langnau im Emmental')
    expect(@normalizer.normalize('Langnau im Emment')).to eq('Langnau im Emmental')
  end

  test 'should normalize "im Kandertal" suffix' do
    expect(@normalizer.normalize('Reichenbach i.K.')).to eq('Reichenbach im Kandertal')
    expect(@normalizer.normalize('Reichenbach i. K.')).to eq('Reichenbach im Kandertal')
    expect(@normalizer.normalize('Reichenbach I. K.')).to eq('Reichenbach im Kandertal')
    expect(@normalizer.normalize('Reichenbach im Kande')).to eq('Reichenbach im Kandertal')
  end

  test 'should not normalize to name that does not occur in TOWNS' do
    expect(@normalizer.normalize('IM TALBODEN OB DER WEID')).to eq('IM TALBODEN OB DER WEID')
  end

  test 'should panards varients' do
    expect(@normalizer.normalize('PANARD MIGROS GENEVE')).to eq('Club des Panards Migros Genève')
    expect(@normalizer.normalize('CLUB PANARDS MIGROS GENEVE')).to eq('Club des Panards Migros Genève')
    expect(@normalizer.normalize('Club Panards Migros Genève')).to eq('Club des Panards Migros Genève')
  end

end
