class Country < ActiveRecord::Base
  has_many :metro_areas
  
  def self.get(name)
    case name
      when :us
        c = 'United States'
    end
    self.find_by_name(c)
  end
  
  def self.find_countries_with_metros
    MetroArea.find(:all, :include => :country).collect{ |m| m.country }.sort_by{ |c| c.name }.uniq
  end
  
  #Add new function to also select countries without metros
  def self.find_countries_with_and_without_metros
    Country.find(:all)
  end
  
  def states
    State.find(:all, :include => :metro_areas, :conditions => ["metro_areas.id in (?)", metro_area_ids ]).uniq
  end
  
  def metro_area_ids
    metro_areas.map{|m| m.id }
  end
  
end
