module Model

  # Model class of Rubadi
  # All SQL statements have been only tested on PostgreSQL.
  class Rubadi
    @@Q = {
      :save_impression =>
          "INSERT INTO impressions (banner_id, campaign_id, hour_slice)
          VALUES(%{banner_id}, %{campaign_id}, %{hour_slice})",
      :valid_campaign =>
          "SELECT EXISTS(SELECT campaign_id FROM clicks
                         WHERE clicks.campaign_id = %{campaign_id})",
      :top_revenue =>
          "SELECT clicks.banner_id
          FROM (SELECT * FROM clicks WHERE campaign_id=%{campaign_id}) AS clicks
          INNER JOIN conversions
          ON (conversions.click_id = clicks.click_id)
          WHERE clicks.campaign_id = %{campaign_id} AND
                clicks.hour_slice = %{hour_slice} AND
                clicks.banner_id <> %{exclude}
          ORDER BY conversions.revenue DESC",
      :top_clicks =>
          "SELECT banner_id, COUNT(banner_id)
          FROM (
            SELECT banner_id
            FROM clicks
            WHERE clicks.campaign_id = %{campaign_id} AND
                  clicks.hour_slice = %{hour_slice} AND
                  banner_id NOT IN (%{excludes})
          ) AS clicks2
          GROUP BY banner_id
          ORDER BY count DESC
          LIMIT %{limit}",
      :top_clicks_all =>
          "SELECT banner_id, COUNT(banner_id)
          FROM (
            SELECT banner_id
            FROM clicks
            WHERE clicks.campaign_id = %{campaign_id} AND
                  clicks.hour_slice = %{hour_slice} AND
                  clicks.banner_id <> %{exclude}
          ) AS clicks2
          GROUP BY banner_id
          ORDER BY count DESC
          LIMIT 5",
      :random_with_excludes =>
          "SELECT banner_id FROM clicks
          WHERE banner_id NOT IN (%{excludes})
          OFFSET random()*(SELECT reltuples::bigint AS estimate
                            FROM pg_class where relname='clicks') LIMIT %{limit}",
      :random =>
          "SELECT banner_id FROM clicks
           WHERE banner_id <> %{exclude}
           OFFSET random()*(SELECT reltuples::bigint AS estimate
                            FROM pg_class where relname='clicks') LIMIT %{limit}"
    }

    # Finds the hour slice of a minute.
    # Params:
    # +min+:: Minutes of an hour; between 0 and 59.
    def hour_slice(min)
      case min
        when 0..15 then 1
        when 16..30 then 2
        when 31..45 then 3
        when 46..59 then 4
        else 0
      end
    end

    def initialize(campaign, minute)
      @campaign = campaign
      @hour_slice = hour_slice(minute)
    end

    # Finds the banner for a campaign.
    # Params:
    # +exclude+:: banner_id to exclude from search.
    def get_banner(exclude)
      top_revenue_banners = get_top_revenue exclude
      if top_revenue_banners.size >= 5
        top_revenue_banners.shuffle[0]
      elsif top_revenue_banners.size.between?(1, 4) then
        (top_revenue_banners +
          get_top_clicks(top_revenue_banners, 5 - top_revenue_banners.size)
        ).shuffle[0]
      else
        top_clicks = get_top_clicks_all exclude
        if top_clicks.size.zero?
          get_random_banners_no_exclude(5, exclude)[0]
        else
          (top_clicks +
            get_random_banners(top_clicks, 5 - top_clicks.size)
          ).shuffle[0]
        end
      end
    end

    # Checks whether a campaign exists or not.
    def valid_campaign
      $conn.with do |conn|
        rows = conn.exec @@Q[:valid_campaign] %
             {:campaign_id => @campaign, :hour_slice => @hour_slice}
        rows[0]['exists'] == 't'
      end
    end

    # Saves an impression.
    # Params:
    # +banner_id+:: banner id
    def save_impression(banner_id)
      $conn.with do |conn|
        rows = conn.exec @@Q[:save_impression] %
             {:campaign_id => @campaign, :hour_slice => @hour_slice,
              :banner_id => banner_id}
      end
    end

    private

    # Finds the banners of a campaign with highest revenues.
    # Params:
    # +exclude+:: banner_id to exclude from the search. Defaults to -1.
    def get_top_revenue(exclude=-1)
      $conn.with do |conn|
        rows = conn.exec @@Q[:top_revenue] %
            {:campaign_id => @campaign, :hour_slice => @hour_slice,
             :exclude => exclude.to_i}
        rows.collect { |row| row['banner_id'] }
      end
    end

    # Finds the banners of a campaign with highest click counts.
    # Params:
    # +exclude+:: list of banner_ids to exclude from the search.
    # +limit+:: how many banner_ids should it return.
    def get_top_clicks(excludes, limit)
      $conn.with do |conn|
        puts excludes.to_s
        rows = conn.exec @@Q[:top_clicks] %
            {:campaign_id => @campaign, :hour_slice => @hour_slice,
             :excludes => excludes.join(','), :limit => limit}
        rows.collect { |row| row['banner_id'] }
      end
    end

    # Finds the banners with highest click counts.
    # Params:
    # +exclude+:: banner_id to exclude from the search. Defaults to -1.
    def get_top_clicks_all(exclude=-1)
      $conn.with do |conn|
        rows = conn.exec @@Q[:top_clicks_all] %
             {:campaign_id => @campaign, :hour_slice => @hour_slice,
              :exclude => exclude}
        rows.collect { |row| row['banner_id'] }
      end
    end

    # Finds random banners
    # Params:
    # +excludes+:: Exclude from banner list when searching
    # +limit+:: How many banners to find
    def get_random_banners(excludes, limit)
      $conn.with do |conn|
        rows = conn.exec @@Q[:random] %
             {:excludes => excludes.join(','), :limit => limit}
        rows.collect { |row| row['banner_id'] }
      end
    end

    # Finds random banners
    # Params:
    # +limit+:: how many banner_ids should it return.
    # +exclude+:: banner_id to exclude from the search. Defaults to -1.
    def get_random_banners_no_exclude(limit, exclude=-1)
      $conn.with do |conn|
        rows = conn.exec @@Q[:random] % {:limit => limit, :exclude => exclude}
        rows.collect { |row| row['banner_id'] }
      end
    end

  end

  # Caching mechanism for Rubadi using Redis.
  class Cache

    # Fetches the cached banner_id for a given campaign_id, host and browser.
    # Params:
    # +key+:: key
    def get(key)
      banner_id = $redis.get key
      !banner_id ? -1 : banner_id
    end

    # Caches a value for a given campaign_id, host and browser.
    # Params:
    # +key+:: key
    # +banner_id+:: banner_id
    def set(key, banner_id)
      $redis.set key, banner_id
    end

  end

end
