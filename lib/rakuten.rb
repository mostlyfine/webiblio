require "open-uri"
require "json"
require "uri"

class Rakuten
  attr_accessor :application_id

  def initialize(application_id)
    @application_id = application_id
  end

  def request(url)
    JSON.parse(open(url).read, symbolize_names: true)
  end

  def default_parameter
    {applicationId: application_id, formatVersion: 2}
  end

  def queries(params)
    params.map {|key, value| "#{URI.encode(key.to_s)}=#{URI.encode(value.to_s)}" }.compact.sort! * '&'
  end

  def api(search, params)
    query = queries(default_parameter.merge(params))
    "https://app.rakuten.co.jp/services/api/Books#{search.to_s}/Search/20130522?#{query}"
  end

  def search(code)
    result = book(code)
    result = cd(code) if result["hits"] == 0
    result = dvd(code) if result["hits"] == 0
    result
  end

  def book(isbn)
    request api(:Book, {isbn: isbn})
  end

  def cd(jan)
    request api(:CD, {jan: jan})
  end

  def dvd(jan)
    request api(:DVD, {jan: jan})
  end
end
