require '../conf'
require 'pg'

# Responsible for importing Ad datasets. It is automatically invoked by cron.
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

  # Import the Ad dataset.
  # Params:
  # +conn+:: database connection
  def do(conn)
    conn.exec @@Q[:trx_begin]
    1.upto 4 do |hour_slice|
      conn.exec @@Q[:import] % {:hour_slice => hour_slice,:import_dir => @import_dir}
    end
    conn.exec @@Q[:trx_end]
  end

end

# Checks if all the conditions match to begin the import process.
# It looks for the import directory and four subdirectories name 1 to 4 and
# required files inside each subdirectory.
# Params:
# +import_dir+:: The root of the import directory.
def run_import?(import_dir)
  Dir.exists? import_dir and
      1.upto(4).reduce(true) { |result, dir|
        full_dir = "#{import_dir}/#{dir}/"
        result and Dir.exists? full_dir and
            File.exists? "#{full_dir}clicks_#{dir}.csv" and
            File.exists? "#{full_dir}conversions_#{dir}.csv" and
            File.exists? "#{full_dir}impressions_#{dir}.csv"
      }
end

# Generates a name for the import directory.
# Params:
# +import_dir+:: import directory
def after_import_name(import_dir)
  time = Time.now
  "#{import_dir}-#{time.year}.#{time.month}.#{time.day}-#{time.hour}.#{time.min}"
end

#
if run_import? CONFIG_IMPORT_DIR
  conn = PGconn.connect(:dbname => CONFIG_DBNAME, :user => CONFIG_DBUSER,
                        :password => CONFIG_DBPWD, :host => CONFIG_DBHOST)
  importer = Import.new CONFIG_IMPORT_DIR
  importer.do conn
  conn.close
  if File.writable? File.dirname CONFIG_IMPORT_DIR
    File.rename CONFIG_IMPORT_DIR, (after_import_name CONFIG_IMPORT_DIR)
  else
    puts <<WARN
Warning! Cannot rename import directory. The same dataset will be imported again
on the next run.
WARN
  end
end

