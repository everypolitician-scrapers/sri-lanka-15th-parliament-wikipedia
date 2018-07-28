#!/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'scraped'
require 'scraperwiki'
require 'wikidata_ids_decorator'

require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

class MembersPage < Scraped::HTML
  decorator WikidataIdsDecorator::Links

  field :members do
    members_table.xpath('.//tr[td]').map { |tr| fragment(tr => MemberRow).to_h }
  end

  private

  def members_table
    noko.xpath('//table[.//th[contains(.,"Preference")]]')
  end
end

class MemberRow < Scraped::HTML
  field :name do
    tds[0].css('a').map(&:text).map(&:tidy).first
  end

  field :id do
    tds[0].css('a/@wikidata').map(&:text).first
  end

  field :area do
    tds[1].text.tidy
  end

  field :area_id do
    tds[1].css('a/@wikidata').map(&:text).first
  end

  field :party do
    tds[10].text.tidy
  end

  field :party_id do
    tds[10].css('a/@wikidata').map(&:text).first
  end

  field :alliance do
    tds[12].text.tidy
  end

  field :alliance_id do
    tds[12].css('a/@wikidata').map(&:text).first
  end

  private

  def tds
    noko.css('td')
  end
end

url = 'https://en.wikipedia.org/wiki/15th_Parliament_of_Sri_Lanka'
Scraped::Scraper.new(url => MembersPage).store(:members, index: %i[name party])
