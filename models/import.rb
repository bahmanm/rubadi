class Import

  @@Q = {
      :trx_begin =>
          'BEGIN TRANSACTION;
          DELETE FROM impressions;
          DELETE FROM clicks;
          DELETE FROM conversions;',
      :trx_end => 'COMMIT TRANSACTION;',
      :import =>
       "COPY impressions (banner_id, campaign_id)
        FROM '%{import_dir}/%{hour_slice}/impressions_%{hour_slice}.csv'
        WITH HEADER CSV DELIMITER ',';
        UPDATE impressions SET hour_slice=%{hour_slice} WHERE hour_slice IS NULL;
        COPY clicks (click_id, banner_id, campaign_id)
        FROM '%{import_dir}/%{hour_slice}/clicks_%{hour_slice}.csv'
        WITH HEADER CSV DELIMITER ',';
        UPDATE clicks SET hour_slice=%{hour_slice} WHERE hour_slice IS NULL;
        COPY conversions (conversion_id, click_id, revenue)
        FROM '%{import_dir}/%{hour_slice}/conversions_%{hour_slice}.csv'
        WITH HEADER CSV DELIMITER ',';
        UPDATE conversions SET hour_slice=%{hour_slice} WHERE hour_slice IS NULL;",
  }

  def initialize(import_dir)
    @import_dir = import_dir
  end

  def do(conn)
    conn.exec @@Q[:trx_begin]
    1.upto 4 do |hour_slice|
      conn.exec @@Q[:import] % {:hour_slice => hour_slice,:import_dir => @import_dir}
    end
    conn.exec @@Q[:trx_end]
  end

end
