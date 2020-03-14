require_relative 'aws-pa'

class Bamz
  def initialize
    @pa5 = AwsPA5.new
  end

  def search(text)
    result = @pa5.search(text)
    result.dig('SearchResult', 'Items').to_a.map do |item|
      title = item.dig('ItemInfo', 'Title', 'DisplayValue')
      ean = item.dig('ItemInfo', 'ExternalIds', 'EANs', 'DisplayValues', 0)
      link = item.dig('DetailPageURL')
      image = item.dig('Images', 'Primary', 'Medium', 'URL')
      image_small = item.dig('Images', 'Primary', 'Small', 'URL')
      manufacturer = item.dig(*%w(ItemInfo ByLineInfo Manufacturer DisplayValue))
      contributors = item.dig(*%w(ItemInfo ByLineInfo Contributors)).to_a.map {|x| x.dig('Name')}.join(", ")
      {
        'title' => title,
        'ean' => ean,
        'link' => link,
        'img' => image,
        'img_small' => image_small,
        'contributors' => contributors,
        'manufacturer' => manufacturer
      } 
    end
  end
end