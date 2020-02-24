require 'net/http'
require 'aws-sigv4'
require 'json'
require 'uri'
require 'net/http'

class AwsPA5
  Resources = [
    "BrowseNodeInfo.BrowseNodes",
    "BrowseNodeInfo.BrowseNodes.Ancestor",
    "BrowseNodeInfo.BrowseNodes.SalesRank",
    "BrowseNodeInfo.WebsiteSalesRank",
    "CustomerReviews.Count",
    "CustomerReviews.StarRating",
    "Images.Primary.Small",
    "Images.Primary.Medium",
    "Images.Primary.Large",
    "Images.Variants.Small",
    "Images.Variants.Medium",
    "Images.Variants.Large",
    "ItemInfo.ByLineInfo",
    "ItemInfo.ContentInfo",
    "ItemInfo.ContentRating",
    "ItemInfo.Classifications",
    "ItemInfo.ExternalIds",
    "ItemInfo.Features",
    "ItemInfo.ManufactureInfo",
    "ItemInfo.ProductInfo",
    "ItemInfo.TechnicalInfo",
    "ItemInfo.Title",
    "ItemInfo.TradeInInfo",
    "Offers.Listings.Availability.MaxOrderQuantity",
    "Offers.Listings.Availability.Message",
    "Offers.Listings.Availability.MinOrderQuantity",
    "Offers.Listings.Availability.Type",
    "Offers.Listings.Condition",
    "Offers.Listings.Condition.SubCondition",
    "Offers.Listings.DeliveryInfo.IsAmazonFulfilled",
    "Offers.Listings.DeliveryInfo.IsFreeShippingEligible",
    "Offers.Listings.DeliveryInfo.IsPrimeEligible",
    "Offers.Listings.DeliveryInfo.ShippingCharges",
    "Offers.Listings.IsBuyBoxWinner",
    "Offers.Listings.LoyaltyPoints.Points",
    "Offers.Listings.MerchantInfo",
    "Offers.Listings.Price",
    "Offers.Listings.ProgramEligibility.IsPrimeExclusive",
    "Offers.Listings.ProgramEligibility.IsPrimePantry",
    "Offers.Listings.Promotions",
    "Offers.Listings.SavingBasis",
    "Offers.Summaries.HighestPrice",
    "Offers.Summaries.LowestPrice",
    "Offers.Summaries.OfferCount",
    "ParentASIN",
    "RentalOffers.Listings.Availability.MaxOrderQuantity",
    "RentalOffers.Listings.Availability.Message",
    "RentalOffers.Listings.Availability.MinOrderQuantity",
    "RentalOffers.Listings.Availability.Type",
    "RentalOffers.Listings.BasePrice",
    "RentalOffers.Listings.Condition",
    "RentalOffers.Listings.Condition.SubCondition",
    "RentalOffers.Listings.DeliveryInfo.IsAmazonFulfilled",
    "RentalOffers.Listings.DeliveryInfo.IsFreeShippingEligible",
    "RentalOffers.Listings.DeliveryInfo.IsPrimeEligible",
    "RentalOffers.Listings.DeliveryInfo.ShippingCharges",
    "RentalOffers.Listings.MerchantInfo",
    "SearchRefinements"
  ]

  def initialize(rsrc_pattern=["Images", "ItemInfo", "ParentASIN"])
    if rsrc_pattern
      @resources = resrouces_filter(rsrc_pattern)
    else
      @resources = Resources.dup
    end

    @signer = Aws::Sigv4::Signer.new(
      service: 'ProductAdvertisingAPI',
      region: 'us-west-2',
      access_key_id: ENV['AWS_PA_KEY_ID'],
      secret_access_key: ENV['AWS_PA_ACCESS_KEY']
     )    
  end

  def resrouces_filter(pattern)
    Resources.find_all do |x|
      pattern.find do |y|
        x.start_with?(y)
      end
    end
  end

  def search(keywords)
    body = payload(keywords)
    signature = @signer.sign_request(
      http_method: 'POST',
      url: 'https://webservices.amazon.com/paapi5/searchitems',
      headers: {
        'host' => 'webservices.amazon.co.jp',
        'content-type' => "application/json; charset=UTF-8",
        "x-amz-target" => "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.SearchItems",
        "content-encoding" => "amz-1.0"
      },
      body: body
     )

    url = URI('https://webservices.amazon.co.jp/paapi5/searchitems')
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new(url)
    request.body = body
    request["host"] = signature.headers['host']
    request['content-type'] = "application/json; charset=UTF-8"
    request['x-amz-target'] = "com.amazon.paapi5.v1.ProductAdvertisingAPIv1.SearchItems"
    request['content-encoding'] = 'amz-1.0'
    signature.headers.each do |k, v|
      request[k] = v
    end

    response = http.request(request)
    result = response.read_body
    JSON.parse(result)
  end

  def payload(keywords)
    {
      "Keywords" => keywords,
      "Resources" => @resources,
      "PartnerTag" => "ilikeruby-22",
      "PartnerType" => "Associates",
      "Marketplace" => "www.amazon.co.jp"
    }.to_json
  end
end

if __FILE__ == $0
  pa5 = AwsPA5.new
  it = pa5.search("4971660030828")
  pp it
end