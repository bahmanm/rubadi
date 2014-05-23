# Model class of Rubadi
# All SQL statements have been only tested on PostgreSQL.
class Rubadi
  @@Q = {
    :valid_campaign =>
        "SELECT campaign_id FROM clicks
        INNER JOIN conversions ON (conversions.click_id = clicks.click_id)
        WHERE clicks.campaign_id = %{campaign_id}",
    :top_revenue =>
        "SELECT clicks.banner_id
        FROM (SELECT * FROM clicks WHERE campaign_id=%{campaign_id}) AS clicks
        INNER JOIN conversions
        ON (conversions.click_id = clicks.click_id)
        WHERE clicks.campaign_id = %{campaign_id} AND
              clicks.hour_slice = %{hour_slice}
        ORDER BY conversions.revenue DESC
        LIMIT 10",
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
                clicks.hour_slice = %{hour_slice}
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
         OFFSET random()*(SELECT reltuples::bigint AS estimate
                          FROM pg_class where relname='clicks') LIMIT %{limit}"
  }

  # Finds the hour slice of a minute.
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
  def get_banner
    top_revenue_banners = get_top_revenue
    if top_revenue_banners.size >= 5
      (top_revenue_banners.shuffle)[0]
    elsif top_revenue_banners.size.between?(1, 4) then
      ((top_revenue_banners +
          get_top_clicks(
              top_revenue_banners, 5 - top_revenue_banners.size)
        ).shuffle
      )[0]
    else
      top_clicks = get_top_clicks_all
      if top_clicks.size.zero?
        get_random_banners_no_exclude(5)[0]
      else
        ((top_clicks +
            get_random_banners(top_clicks, 5 - top_clicks.size)
          ).shuffle
        )[0]
      end
    end
  end

  # Checks whether a campaign exists or not.
  def valid_campaign
    $conn.with do |conn|
      rows = conn.exec @@Q[:valid_campaign] %
           {:campaign_id => @campaign, :hour_slice => @hour_slice}
      not rows.count.zero?
    end
  end

  private

  # Finds the banners of a campaign with highest revenues.
  def get_top_revenue
    $conn.with do |conn|
      rows = conn.exec @@Q[:top_revenue] %
          {:campaign_id => @campaign, :hour_slice => @hour_slice}
      rows.collect { |row| row['banner_id'] }
    end
  end

  # Finds the banners of a campaign with highest click counts.
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
  def get_top_clicks_all
    $conn.with do |conn|
      rows = conn.exec @@Q[:top_clicks_all] %
           {:campaign_id => @campaign, :hour_slice => @hour_slice}
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
  def get_random_banners_no_exclude(limit)
    $conn.with do |conn|
      rows = conn.exec @@Q[:random] % {:limit => limit}
      rows.collect { |row| row['banner_id'] }
    end
  end

end
